#!/usr/bin/env bash
set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Tailscale Exit Node - One-Command Installer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check prerequisites
echo -e "${BLUE}[1/4]${NC} Checking prerequisites..."

if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗ Error: Docker is not installed${NC}"
    echo ""
    echo "Please install Docker first:"
    echo "  curl -fsSL https://get.docker.com | sh"
    exit 1
fi

if ! command -v git &> /dev/null; then
    echo -e "${RED}✗ Error: Git is not installed${NC}"
    echo ""
    echo "Please install Git first:"
    echo "  sudo apt-get install git -y  # Debian/Ubuntu"
    echo "  sudo yum install git -y      # RHEL/CentOS"
    exit 1
fi

# Check Docker Compose v2
if ! docker compose version &> /dev/null; then
    echo -e "${RED}✗ Error: Docker Compose v2 is not available${NC}"
    echo ""
    echo "Please install Docker Compose v2:"
    echo "  https://docs.docker.com/compose/install/"
    exit 1
fi

# Check Docker permissions
if ! docker ps &> /dev/null; then
    echo -e "${YELLOW}⚠ Warning: Docker permission denied${NC}"
    echo ""
    echo "Adding current user to docker group..."
    sudo usermod -aG docker $USER
    echo ""
    echo -e "${YELLOW}Please logout and login again, then re-run this installer.${NC}"
    echo "Or run: newgrp docker"
    exit 1
fi

echo -e "${GREEN}✓ All prerequisites met${NC}"
echo ""

# Set installation directory
INSTALL_DIR="$HOME/tailscale-exit-node"

# Check if already installed
if [ -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}[2/4]${NC} Directory already exists: $INSTALL_DIR"
    echo ""
    read -p "Do you want to reinstall? This will remove the existing installation. (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Removing existing installation..."
        cd "$INSTALL_DIR"
        docker compose down 2>/dev/null || true
        cd ..
        rm -rf "$INSTALL_DIR"
        echo -e "${GREEN}✓ Removed existing installation${NC}"
    else
        echo "Installation cancelled."
        exit 0
    fi
fi

# Clone repository
echo -e "${BLUE}[2/4]${NC} Downloading project files..."
git clone https://github.com/devtux7/tailscale.git "$INSTALL_DIR" --quiet

if [ ! -d "$INSTALL_DIR" ]; then
    echo -e "${RED}✗ Failed to clone repository${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Project files downloaded${NC}"
echo ""

# Change to project directory
cd "$INSTALL_DIR"

# Make scripts executable
chmod +x start.sh entrypoint.sh

# Run start.sh
echo -e "${BLUE}[3/4]${NC} Starting Tailscale Exit Node..."
echo ""

./start.sh

# Final info
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✓ Installation Complete!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Project installed at: $INSTALL_DIR"
echo ""
echo "Useful commands:"
echo "  • View logs:          docker logs tailscale-exit-node"
echo "  • Check status:       docker exec tailscale-exit-node tailscale status"
echo "  • Stop container:     cd $INSTALL_DIR && docker compose down"
echo "  • Restart:            cd $INSTALL_DIR && ./start.sh"
echo "  • Uninstall:          cd $INSTALL_DIR && docker compose down && cd .. && rm -rf tailscale-exit-node"
echo ""
