#!/bin/bash
set -e

# Complete release build for macport
# This script orchestrates the entire build process: icon → app → dmg

VERSION="0.1.0"

echo "🚀 macport Release Build Pipeline"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Version: ${VERSION}"
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

# Step 2: Build .app bundle
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
echo "Artifacts created:"
echo "  • App bundle: target/release/macport.app"
echo "  • DMG installer: target/release/macport-${VERSION}.dmg"
echo ""
echo "Next steps:"
echo "  1. Test the DMG: open target/release/macport-${VERSION}.dmg"
echo "  2. Create a GitHub release: gh release create v${VERSION}"
echo "  3. Upload the DMG to the release"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
