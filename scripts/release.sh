#!/bin/bash
set -e

# Complete release build for PortKiller
# This script orchestrates the entire build process: clean → build → app → dmg

VERSION="0.1.0"
APP_NAME="PortKiller"

echo "🚀 ${APP_NAME} Release Build Pipeline"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Version: ${VERSION}"
echo ""

# Step 0: Clean previous builds to avoid stale binaries
echo "🧹 Cleaning previous builds..."
rm -rf target/release/${APP_NAME}.app
rm -f target/release/${APP_NAME}-*.dmg
rm -f target/release/portkiller
cargo clean --release
echo "✓ Clean complete"
echo ""

# Step 1: Check if icon exists, create if needed
if [ ! -f "assets/AppIcon.icns" ]; then
    echo "🎨 Icon not found, creating default icon..."
    ./scripts/create-icon.sh
    echo ""
else
    echo "✓ Icon already exists"
    echo ""
fi

# Step 2: Build .app bundle (includes cargo build --release)
echo "🔨 Building .app bundle..."
./scripts/build-app.sh
echo ""

# Step 3: Create DMG
echo "📦 Creating DMG..."
./scripts/create-dmg.sh
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 Release build complete!"
echo ""
echo "Artifacts created (fresh build from clean state):"
echo "  • App bundle: target/release/${APP_NAME}.app"
echo "  • DMG installer: target/release/${APP_NAME}-${VERSION}.dmg"
echo ""
echo "Next steps:"
echo "  1. Test the .app: open target/release/${APP_NAME}.app"
echo "  2. Test the DMG: open target/release/${APP_NAME}-${VERSION}.dmg"
echo "  3. Create a GitHub release: gh release create v${VERSION}"
echo "  4. Upload the DMG to the release"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
