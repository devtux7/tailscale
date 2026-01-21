#!/usr/bin/env bash
set -e

# Colors for pretty output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Tailscale Exit Node - Startup Script"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Step 1: Start container
echo -e "${BLUE}[1/3]${NC} Starting container..."
docker compose up -d

# Step 2: Wait for container to be running
echo -e "${BLUE}[2/3]${NC} Waiting for container to initialize..."
sleep 3

# Wait for log file to exist
echo -e "${BLUE}[3/3]${NC} Checking authentication status..."
for i in $(seq 1 10); do
  if docker exec tailscale-exit-node test -f /tmp/tailscaled.log 2>/dev/null; then
    break
  fi
  sleep 1
done

# Monitor logs for up to 30 seconds
TIMEOUT=30
ELAPSED=0
AUTH_URL=""
DOTS=""

while [ $ELAPSED -lt $TIMEOUT ]; do
  # Try to get auth URL from daemon logs
  AUTH_URL=$(docker exec tailscale-exit-node cat /tmp/tailscaled.log 2>/dev/null | grep -o 'https://login.tailscale.com/a/[a-zA-Z0-9]*' | tail -1 || true)
  
  if [ -n "$AUTH_URL" ]; then
    break
  fi
  
  # Show progress dots
  DOTS="${DOTS}."
  if [ ${#DOTS} -gt 3 ]; then
    DOTS=""
  fi
  printf "\r   Waiting for authentication${DOTS}   "
  
  sleep 1
  ELAPSED=$((ELAPSED + 1))
done

# Display results
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ -n "$AUTH_URL" ]; then
  echo -e "${YELLOW}🔐 Authentication Required${NC}"
  echo ""
  echo "To authenticate, visit:"
  echo ""
  echo -e "${GREEN}    $AUTH_URL${NC}"
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "After authentication:"
  echo "  1. Go to Tailscale Admin Console: https://login.tailscale.com/admin/machines"
  echo "  2. Find 'container-tailscale' and approve it as an exit node"
  echo ""
else
  # Already authenticated
  echo -e "${GREEN}✓ Container is running${NC}"
  echo ""
  docker exec tailscale-exit-node tailscale status 2>/dev/null || true
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
fi

echo ""
echo "Useful commands:"
echo "  • View logs:        docker logs tailscale-exit-node"
echo "  • Check status:     docker exec tailscale-exit-node tailscale status"
echo "  • Stop container:   docker-compose down"
echo ""
