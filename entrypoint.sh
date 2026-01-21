#!/usr/bin/env sh
set -e

echo "────────────────────────────────────────────────────────"
echo "🚀 Tailscale Exit Node - Starting..."
echo "────────────────────────────────────────────────────────"
echo ""
echo "⏳ Initializing... (this takes ~5-10 seconds)"
echo ""

# ============================================
# PERFORMANCE OPTIMIZATIONS
# ============================================

# Enable IP Forwarding (critical for exit node)
sysctl -w net.ipv4.ip_forward=1 >/dev/null 2>&1 || true
sysctl -w net.ipv6.conf.all.forwarding=1 >/dev/null 2>&1 || true

# TCP BBR Congestion Control (improved throughput)
sysctl -w net.core.default_qdisc=fq >/dev/null 2>&1 || true
sysctl -w net.ipv4.tcp_congestion_control=bbr >/dev/null 2>&1 || true

# UDP Buffer Tuning (critical for WireGuard performance)
sysctl -w net.core.rmem_max=2500000 >/dev/null 2>&1 || true
sysctl -w net.core.wmem_max=2500000 >/dev/null 2>&1 || true

# TCP Buffer Tuning
sysctl -w net.ipv4.tcp_rmem="4096 87380 6291456" >/dev/null 2>&1 || true
sysctl -w net.ipv4.tcp_wmem="4096 16384 4194304" >/dev/null 2>&1 || true

# Additional network performance settings
sysctl -w net.ipv4.tcp_fastopen=3 >/dev/null 2>&1 || true
sysctl -w net.ipv4.tcp_slow_start_after_idle=0 >/dev/null 2>&1 || true
sysctl -w net.ipv4.tcp_mtu_probing=1 >/dev/null 2>&1 || true

# Connection tracking optimizations
sysctl -w net.netfilter.nf_conntrack_max=1000000 >/dev/null 2>&1 || true
sysctl -w net.netfilter.nf_conntrack_tcp_timeout_established=86400 >/dev/null 2>&1 || true

echo "✓ Performance optimizations applied"

# ============================================
# TUN/TAP DEVICE SETUP
# ============================================

if [ ! -d /dev/net ]; then
  mkdir -p /dev/net
fi

if [ ! -c /dev/net/tun ]; then
  mknod /dev/net/tun c 10 200
  chmod 600 /dev/net/tun
fi

echo "✓ TUN/TAP device configured"

# ============================================
# START TAILSCALE
# ============================================

# Start tailscaled in background, redirect logs to file
tailscaled \
  --state=/var/lib/tailscale/tailscaled.state \
  --socket=/var/run/tailscale/tailscaled.sock \
  > /tmp/tailscaled.log 2>&1 &

# Wait for tailscaled to be ready (increased timeout)
for i in $(seq 1 30); do
  if tailscale status >/dev/null 2>&1; then
    # Give it one more second to be fully ready
    sleep 1
    break
  fi
  sleep 0.5
done

echo "✓ Tailscaled daemon started"

# TS_HOSTNAME yoksa, container hostname'ini kullan
TAILSCALE_HOSTNAME="${TS_HOSTNAME:-$(hostname)}"

echo ""
echo "📋 Configuration:"
echo "   • Hostname: ${TAILSCALE_HOSTNAME}"
echo "   • Exit Node: Enabled"
echo "   • Routes: Accepting all routes"
echo ""

# Bring up Tailscale
tailscale up \
  --hostname="${TAILSCALE_HOSTNAME}" \
  --advertise-exit-node \
  --accept-routes >/dev/null 2>&1 &

# Wait a moment for auth URL to appear in logs if needed
sleep 2

# Check if we need authentication by looking at daemon logs
AUTH_URL=$(grep -o 'https://login.tailscale.com/a/[a-zA-Z0-9]*' /tmp/tailscaled.log 2>/dev/null | tail -1)

if [ -n "$AUTH_URL" ]; then
  echo "────────────────────────────────────────────────────────"
  echo "🔐 Authentication Required"
  echo "────────────────────────────────────────────────────────"
  echo ""
  echo "To authenticate, visit:"
  echo ""
  echo "    $AUTH_URL"
  echo ""
  echo "────────────────────────────────────────────────────────"
else
  # Wait for tailscale up to complete
  wait
  echo "✓ Already authenticated"
  echo ""
  tailscale status 2>/dev/null || true
fi

echo ""
echo "✓ Tailscale Exit Node is running"
echo ""
echo "💡 Tip: Verbose logs available at /tmp/tailscaled.log"
echo ""

# Keep container running
tail -f /dev/null
