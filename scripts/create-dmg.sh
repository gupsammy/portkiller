#!/bin/bash
set -e

# Create distributable DMG for macport
# This script packages the .app bundle into a DMG for easy distribution

APP_NAME="macport"
VERSION="0.1.0"
BUILD_DIR="target/release"
APP_BUNDLE="${BUILD_DIR}/${APP_NAME}.app"
DMG_NAME="${APP_NAME}-${VERSION}.dmg"
DMG_DIR="${BUILD_DIR}/dmg"
VOLUME_NAME="macport ${VERSION}"

echo "📦 Creating DMG for macport..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Step 1: Verify .app bundle exists
if [ ! -d "${APP_BUNDLE}" ]; then
    echo "❌ Error: ${APP_BUNDLE} not found!"
    echo "   Run ./scripts/build-app.sh first"
    exit 1
fi

# Step 2: Clean previous DMG artifacts
echo "🧹 Cleaning previous builds..."
rm -rf "${DMG_DIR}"
rm -f "${BUILD_DIR}/${DMG_NAME}"
rm -f "${BUILD_DIR}/${APP_NAME}-temp.dmg"

# Step 3: Create DMG staging directory
echo "📁 Creating staging directory..."
mkdir -p "${DMG_DIR}"

# Step 4: Copy app bundle to staging
echo "📋 Copying ${APP_NAME}.app..."
cp -R "${APP_BUNDLE}" "${DMG_DIR}/"

# Step 5: Create symbolic link to Applications folder
echo "🔗 Creating Applications symlink..."
ln -s /Applications "${DMG_DIR}/Applications"

# Step 6: Create temporary DMG
echo "💾 Creating temporary DMG..."
hdiutil create \
    -volname "${VOLUME_NAME}" \
    -srcfolder "${DMG_DIR}" \
    -ov \
    -format UDRW \
    "${BUILD_DIR}/${APP_NAME}-temp.dmg"

# Step 7: Mount temporary DMG for customization
echo "🔧 Mounting DMG for customization..."
DEVICE=$(hdiutil attach -readwrite -noverify -noautoopen "${BUILD_DIR}/${APP_NAME}-temp.dmg" | \
    grep -E '^/dev/' | sed 1q | awk '{print $1}')

# Wait for mount
sleep 2

# Step 8: Customize DMG appearance
echo "🎨 Customizing DMG appearance..."
MOUNT_PATH="/Volumes/${VOLUME_NAME}"

# Set DMG window properties using AppleScript
osascript <<EOF
tell application "Finder"
    tell disk "${VOLUME_NAME}"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {400, 100, 900, 450}
        set viewOptions to the icon view options of container window
        set arrangement of viewOptions to not arranged
        set icon size of viewOptions to 96
        set position of item "${APP_NAME}.app" of container window to {125, 175}
        set position of item "Applications" of container window to {375, 175}
        update without registering applications
        delay 2
        close
    end tell
end tell
EOF

# Step 9: Sync changes
sync

# Step 10: Unmount temporary DMG
echo "📤 Unmounting temporary DMG..."
hdiutil detach "${DEVICE}" -quiet

# Step 11: Convert to compressed read-only DMG
echo "🗜️  Creating final compressed DMG..."
hdiutil convert \
    "${BUILD_DIR}/${APP_NAME}-temp.dmg" \
    -format UDZO \
    -imagekey zlib-level=9 \
    -o "${BUILD_DIR}/${DMG_NAME}"

# Step 12: Clean up
echo "🧹 Cleaning up temporary files..."
rm -rf "${DMG_DIR}"
rm -f "${BUILD_DIR}/${APP_NAME}-temp.dmg"

# Step 13: Calculate DMG size
DMG_SIZE=$(du -h "${BUILD_DIR}/${DMG_NAME}" | cut -f1)

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ DMG created successfully!"
echo ""
echo "📦 File: ${BUILD_DIR}/${DMG_NAME}"
echo "📊 Size: ${DMG_SIZE}"
echo ""
echo "🚀 To distribute:"
echo "   1. Test installation:"
echo "      open ${BUILD_DIR}/${DMG_NAME}"
echo ""
echo "   2. Upload to GitHub Releases:"
echo "      gh release create v${VERSION} ${BUILD_DIR}/${DMG_NAME}"
echo ""
echo "   3. Or share directly:"
echo "      The DMG is ready for distribution!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
