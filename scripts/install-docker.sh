#!/usr/bin/env bash
set -e

echo "🔹 Installing Docker & Docker Compose (latest) on Ubuntu"

# Ensure script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run as root (use sudo)"
  exit 1
fi

# Remove old versions if present
echo "🔹 Removing old Docker versions (if any)"
apt-get remove -y docker docker-engine docker.io containerd runc || true

# Update system
echo "🔹 Updating package index"
apt-get update -y

# Install prerequisites
echo "🔹 Installing dependencies"
apt-get install -y \
  ca-certificates \
  curl \
  gnupg \
  lsb-release

# Add Docker’s official GPG key
echo "🔹 Adding Docker GPG key"
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo "🔹 Adding Docker repository"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" \
  > /etc/apt/sources.list.d/docker.list

# Install Docker Engine & Compose plugin
echo "🔹 Installing Docker Engine & Docker Compose"
apt-get update -y
apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

# Enable and start Docker
echo "🔹 Enabling Docker service"
systemctl enable docker
systemctl start docker

# Add invoking user to docker group
if [ -n "$SUDO_USER" ]; then
  echo "🔹 Adding user '$SUDO_USER' to docker group"
  usermod -aG docker "$SUDO_USER"
fi

echo "✅ Docker & Docker Compose installed successfully!"
echo
echo "📌 Versions:"
docker --version
docker compose version

echo
echo "⚠️ Log out and log back in (or reboot) to use Docker without sudo"
