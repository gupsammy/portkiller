#!/bin/bash
# portkiller installer - One-line installation script
# Usage: curl -fsSL https://raw.githubusercontent.com/gupsammy/PortKiller/master/install.sh | bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
REPO="gupsammy/PortKiller"
INSTALL_DIR="/usr/local/bin"
BINARY_NAME="portkiller"
TEMP_DIR=$(mktemp -d)

# Cleanup function
cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

# Print functions
print_error() {
    echo -e "${RED}Error: $1${NC}" >&2
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}→ $1${NC}"
}

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This application is only supported on macOS"
    exit 1
fi

# Check for required commands
for cmd in curl tar sudo; do
    if ! command -v $cmd &> /dev/null; then
        print_error "Required command '$cmd' not found"
        exit 1
    fi
done

echo ""
print_info "Installing portkiller..."
echo ""

# Get the latest release URL
print_info "Fetching latest release information..."
LATEST_RELEASE=$(curl -s "https://api.github.com/repos/$REPO/releases/latest")
DOWNLOAD_URL=$(echo "$LATEST_RELEASE" | grep "browser_download_url.*macos.tar.gz" | cut -d '"' -f 4)

if [ -z "$DOWNLOAD_URL" ]; then
    print_error "Could not find release download URL"
    print_info "Please visit https://github.com/$REPO/releases for manual installation"
    exit 1
fi

VERSION=$(echo "$LATEST_RELEASE" | grep '"tag_name"' | cut -d '"' -f 4)
print_success "Found version $VERSION"

# Download the release
print_info "Downloading portkiller..."
if ! curl -fsSL "$DOWNLOAD_URL" -o "$TEMP_DIR/portkiller.tar.gz"; then
    print_error "Failed to download release"
    exit 1
fi
print_success "Download complete"

# Extract the tarball
print_info "Extracting files..."
if ! tar -xzf "$TEMP_DIR/portkiller.tar.gz" -C "$TEMP_DIR"; then
    print_error "Failed to extract archive"
    exit 1
fi

# Find the binary (it might be in a subdirectory)
BINARY_PATH=$(find "$TEMP_DIR" -name "$BINARY_NAME" -type f | head -n 1)

if [ -z "$BINARY_PATH" ]; then
    print_error "Could not find $BINARY_NAME binary in the archive"
    exit 1
fi

print_success "Extraction complete"

# Create install directory if it doesn't exist
if [ ! -d "$INSTALL_DIR" ]; then
    print_info "Creating $INSTALL_DIR directory..."
    sudo mkdir -p "$INSTALL_DIR"
fi

# Install the binary
print_info "Installing to $INSTALL_DIR/$BINARY_NAME..."
if ! sudo cp "$BINARY_PATH" "$INSTALL_DIR/$BINARY_NAME"; then
    print_error "Failed to install binary"
    exit 1
fi

# Set executable permissions
sudo chmod +x "$INSTALL_DIR/$BINARY_NAME"

# Remove quarantine attribute (macOS security)
print_info "Removing quarantine attribute..."
sudo xattr -dr com.apple.quarantine "$INSTALL_DIR/$BINARY_NAME" 2>/dev/null || true

print_success "Installation complete!"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
print_success "portkiller $VERSION has been installed successfully!"
echo ""
echo "  To launch: portkiller"
echo ""
echo "  Config file: ~/.portkiller.json"
echo "  Edit config from menu: Click portkiller icon → Edit Configuration"
echo ""
echo "  To uninstall: sudo rm $INSTALL_DIR/$BINARY_NAME"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
