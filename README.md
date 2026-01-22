# 🚀 Tailscale Exit Node (Docker) - Performance Optimized

Dockerize edilmiş, performans odaklı Tailscale Exit Node çözümü.

## ✨ Özellikler

- ✅ **Performans Optimizasyonları**: TCP BBR, UDP buffer tuning, connection tracking
- ✅ **Otomatik Healthcheck**: Container sağlığı izleme
- ✅ **Log Rotation**: Disk dolmasını önlemek için otomatik log yönetimi
- ✅ **Güvenli Authentication**: Manuel login (auth key kullanılmıyor)
- ✅ **Persistent State**: Container restart sonrası bağlantı korunur

## 📋 Performans İyileştirmeleri

Bu setup aşağıdaki optimizasyonları otomatik uygular:

### Network Stack
- **TCP BBR Congestion Control**: Daha iyi throughput ve latency
- **IP Forwarding**: IPv4 ve IPv6 için aktif
- **TCP Fast Open**: Bağlantı kurulum hızlandırması
- **MTU Probing**: Optimal paket boyutu belirleme

### Buffer Tuning
- **UDP Buffers**: 2.5MB (WireGuard performansı için kritik)
- **TCP Buffers**: Geliştirilmiş okuma/yazma buffer boyutları

### Connection Tracking
- **Max Connections**: 1M simultaneous connection
- **TCP Timeout**: 24 saat established connections için

## 🚀 Hızlı Başlangıç

### 1. Gereksinimler
- Docker
- Docker Compose
- Tailscale hesabı

### 2. Kurulum

**En Kolay Yol (Önerilen):**
```bash
bash <(curl -fsSL https://dub.sh/tailscale.sh)
```
veya 

```bash
./start.sh
```

Bu script:
- ✅ Container'ı başlatır
- ✅ Authentication URL'ini otomatik yakalar
- ✅ Size güzel bir şekilde gösterir
- ✅ Tek komut, tüm işlem!

**Manuel Yol:**
```bash
# Container'ı başlat
docker-compose up -d

# Logları canlı takip et (authentication URL görününce Ctrl+C ile çık)
docker logs -f tailscale-exit-node
```

**Beklenen çıktı:**
```
────────────────────────────────────────────────────────
🚀 Tailscale Exit Node - Starting...
────────────────────────────────────────────────────────

⏳ Initializing... (this takes ~5-10 seconds)

✓ Performance optimizations applied
✓ TUN/TAP device configured
✓ Tailscaled daemon started

📋 Configuration:
   • Hostname: container-tailscale
   • Exit Node: Enabled
   • Routes: Accepting all routes

────────────────────────────────────────────────────────
🔐 Authentication Required
────────────────────────────────────────────────────────

To authenticate, visit:

    https://login.tailscale.com/a/xxxxxxxxxx

────────────────────────────────────────────────────────

✓ Tailscale Exit Node is running

💡 Tip: Verbose logs available at /tmp/tailscaled.log
```

**3. URL'yi tarayıcıda açıp login ol**

### 3. Exit Node'u Aktifleştirme

1. [Tailscale Admin Console](https://login.tailscale.com/admin/machines)'a git
2. Bu makineyi bul (`container-tailscale`)
3. **"Edit route settings..."** → **"Use as exit node"** → **Approve**

## 🌍 Platform Desteği

### Platform Uyumluluk Tablosu

| Platform | Durum | Notlar |
|----------|:-----:|--------|
| **Oracle Cloud Free Tier** | ✅ | En popüler seçenek, firewall ayarı gerekebilir |
| **Hetzner Cloud** | ✅ | Sorunsuz çalışır |
| **Raspberry Pi** | ✅ | ARM desteği mevcut, home server için ideal |
| **DigitalOcean Droplets** | ✅ | Sorunsuz çalışır |
| **AWS EC2** | ✅ | Security group ayarlarına dikkat |
| **Google Cloud (GCE)** | ✅ | Sorunsuz çalışır |
| **Azure VM** | ✅ | Sorunsuz çalışır |
| **Vultr / Linode** | ✅ | Sorunsuz çalışır |
| **Home Server (Linux)** | ✅ | Port forwarding gerekmez |
| **Managed Kubernetes** | ⚠️ | Privileged + host network gerekir |
| **Serverless (Cloud Run, Fargate)** | ❌ | Privileged mode desteklenmez |

### Platform-Specific Deployment Guides

#### 🟠 Oracle Cloud Free Tier

Oracle Cloud'da bazı firewall ayarları gerekebilir:

```bash
# 1. Projeyi klonla ve başlat
./start.sh

# 2. Firewall kurallarını ayarla (bir kerelik)
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT
sudo netfilter-persistent save

# 3. Oracle Cloud Console'dan Security List ayarları
# Ingress Rules: All traffic from 0.0.0.0/0 (veya Tailscale subnet)
```

**Oracle Cloud Free Tier Avantajları:**
- ✅ 4 ARM核 + 24GB RAM (ücretsiz)
- ✅ Her zaman ücretsiz
- ✅ Sınırsız trafik

#### 🍓 Raspberry Pi (Home Server)

```bash
# 1. Docker kurulumu
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# 2. Docker Compose kurulumu
sudo apt-get install docker-compose

# 3. Projeyi çalıştır
./start.sh
```

**Raspberry Pi Avantajları:**
- ✅ Düşük güç tüketimi (~3-5W)
- ✅ Sessiz çalışır
- ✅ Port forwarding gerekmez (Tailscale DERP)
- ✅ Home lab için mükemmel

#### 🟦 Hetzner Cloud

```bash
# 1. CX11 veya daha üst bir instance oluştur
# 2. Docker kurulumu (Ubuntu/Debian)
sudo apt-get update
sudo apt-get install docker.io docker-compose

# 3. Projeyi çalıştır
./start.sh
```

**Hetzner Avantajları:**
- ✅ Uygun fiyat (€3.29/ay CX11)
- ✅ Hızlı network
- ✅ Avrupa lokasyonları

#### 🌊 DigitalOcean

```bash
# 1. Droplet oluştur (Docker One-Click Image)
# 2. Projeyi klonla ve çalıştır
git clone <repo>
cd tailscale-exit-node
./start.sh
```

#### ☁️ AWS EC2

```bash
# 1. EC2 instance başlat (Amazon Linux 2 veya Ubuntu)
# 2. Security Group ayarları
#    - Inbound: UDP 41641 (Tailscale)
#    - Outbound: All traffic

# 3. Docker kurulumu
sudo yum install docker -y  # Amazon Linux
sudo service docker start
sudo usermod -aG docker ec2-user

# 4. Docker Compose kurulumu
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 5. Projeyi çalıştır
./start.sh
```

#### 🏠 Home Server (Genel Linux)

```bash
# 1. Docker ve Docker Compose kurulu olduğundan emin ol
docker --version
docker-compose --version

# 2. Projeyi çalıştır
./start.sh

# 3. Firewall ayarları (isteğe bağlı)
sudo ufw allow 41641/udp  # Tailscale UDP port
```

**Home Server İçin Önemli:**
- ✅ Port forwarding **gerekmez** (Tailscale DERP kullanır)
- ✅ Dynamic IP sorunu olmaz
- ✅ Router ayarı gerekmez
- ✅ ISP sınırlamaları bypass edilir

### Gereksinimler (Tüm Platformlar)

**Minimum:**
- Docker Engine 20.10+
- Docker Compose 1.29+
- 512MB RAM
- 1 CPU core
- 10GB disk space

**Önerilen:**
- 1GB+ RAM
- 2+ CPU cores
- 20GB+ disk space
- Düşük latency network

### Port Gereksinimleri

Tailscale **port forwarding gerektirmez**, ancak optimal performans için:
- **UDP 41641**: Tailscale WireGuard (opsiyonel, NAT traversal için)
- DERP relay serverları otomatik kullanılır (her durumda çalışır)

## 🔧 Yapılandırma

Hostname varsayılan olarak `container-tailscale` olarak ayarlanmıştır. Değiştirmek isterseniz:

**Seçenek 1: docker-compose.yml'de değiştir**
```yaml
hostname: my-custom-exit-node
```

**Seçenek 2: Environment variable ile override et**
```yaml
environment:
  - TS_HOSTNAME=my-custom-exit-node
```

## 📊 Monitoring

### Container Sağlığını Kontrol

```bash
# Healthcheck durumu
docker inspect tailscale-exit-node --format='{{.State.Health.Status}}'

# Tailscale durumu
docker exec tailscale-exit-node tailscale status

# Bağlantı bilgisi
docker exec tailscale-exit-node tailscale netcheck
```

### Log İnceleme

```bash
# Temiz çıktı (user-facing)
docker logs tailscale-exit-node

# Detaylı daemon logları
docker exec tailscale-exit-node cat /tmp/tailscaled.log

# Canlı logları takip et
docker exec tailscale-exit-node tail -f /tmp/tailscaled.log
```

## 🛠️ Sorun Giderme

### Container başlamıyor

```bash
# Logları kontrol et
docker logs tailscale-exit-node

# Container'ı yeniden başlat
docker-compose restart

# Temiz başlangıç (state korunur)
docker-compose down
docker-compose up -d
```

### Performans testi

```bash
# WireGuard istatistikleri (host'ta)
docker exec tailscale-exit-node wg show

# Network performans testi
docker exec tailscale-exit-node tailscale ping <peer-ip>
```

### Sysctl uyarıları alıyorum

Bazı sistemlerde sysctl ayarları başarısız olabilir (virtualized environments). Bu normal, kritik değil:
- Script fail-safe tasarlanmıştır
- Uyarılar göz ardı edilebilir
- Exit node çalışmaya devam eder

## 🔄 Auto-Update (Opsiyonel)

Container'ı otomatik güncellemek için [Watchtower](https://github.com/containrrr/watchtower) kullanabilirsiniz:

```yaml
# docker-compose.yml'e ekleyin
  watchtower:
    image: containrrr/watchtower
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    command: --interval 86400 tailscale-exit-node
```

## 📁 Dosya Yapısı

```
.
├── docker-compose.yml    # Container orchestration
├── entrypoint.sh        # Startup script + optimizations
├── start.sh             # User-friendly startup helper
└── README.md            # Dokümantasyon
```

## 🎯 Kullanım Senaryoları

- ✅ VPS'te exit node (Oracle Cloud, DigitalOcean, etc.)
- ✅ Home server / Raspberry Pi
- ✅ Cloud instances (AWS, GCP, Azure)
- ✅ Development/testing environments

## 📝 Notlar

- **Privileged Mode**: Performans optimizasyonları için gerekli
- **Network Mode Host**: Exit node functionality için şart
- **State Persistence**: `/var/lib/tailscale` volume'de saklanır
- **Log Rotation**: Maksimum 30MB (3 × 10MB dosya)

## 🔗 Kaynaklar

- [Tailscale Exit Nodes](https://tailscale.com/kb/1103/exit-nodes)
- [TCP BBR](https://github.com/google/bbr)
- [Docker Networking](https://docs.docker.com/network/)

## 📄 License

MIT
