#!/bin/bash
set -e

# Create macOS .icns icon for macport
# This script generates a simple icon representing a port/network monitor

ICON_NAME="AppIcon"
ICON_DIR="assets/AppIcon.iconset"
OUTPUT_ICON="assets/AppIcon.icns"

echo "🎨 Creating macport app icon..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Create iconset directory
mkdir -p "${ICON_DIR}"

# Function to create a simple port monitor icon
create_icon() {
    local size=$1
    local output=$2

    # Create a simple icon using ImageMagick (if available) or sips
    # The icon represents a port/network indicator with a circular design

    if command -v magick &> /dev/null || command -v convert &> /dev/null; then
        # Use ImageMagick to create the icon
        local cmd="magick"
        if ! command -v magick &> /dev/null; then
            cmd="convert"
        fi

        $cmd -size ${size}x${size} xc:none \
            -fill "#007AFF" \
            -draw "circle $((size/2)),$((size/2)) $((size/2)),$((size/10))" \
            -fill "white" \
            -draw "circle $((size/2)),$((size/2)) $((size/2)),$((size*3/10))" \
            -fill "#007AFF" \
            -font "Helvetica-Bold" -pointsize $((size/3)) -gravity center \
            -annotate +0+0 "∴" \
            "${output}"
        echo "  ✓ Generated ${size}x${size} icon"
    else
        echo "  ⚠ ImageMagick not found. Creating placeholder icon..."
        # Create a simple colored square as fallback using sips
        # User should replace this with a proper icon
        printf "\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x10\x00\x00\x00\x10\x08\x02\x00\x00\x00\x90\x91h6\x00\x00\x00\x0cIDATx\x9cc\xf8\x0f\x00\x00\x01\x01\x00\x05\x18\r-\xf1\x00\x00\x00\x00IEND\xaeB\x60\x82" > "${output}"
        sips -z ${size} ${size} "${output}" --out "${output}" > /dev/null 2>&1
        echo "  ⚠ Created placeholder ${size}x${size} - replace with custom icon"
    fi
}

# Generate all required icon sizes for macOS
echo "📐 Generating icon sizes..."

# Check if custom icon exists
if [ -f "assets/icon-1024.png" ]; then
    echo "✓ Using custom icon: assets/icon-1024.png"
    BASE_ICON="assets/icon-1024.png"

    # Generate all sizes from the custom icon using sips and optimize
    sips -z 16 16 "${BASE_ICON}" --out "${ICON_DIR}/icon_16x16.png" > /dev/null 2>&1
    sips -z 32 32 "${BASE_ICON}" --out "${ICON_DIR}/icon_16x16@2x.png" > /dev/null 2>&1
    sips -z 32 32 "${BASE_ICON}" --out "${ICON_DIR}/icon_32x32.png" > /dev/null 2>&1
    sips -z 64 64 "${BASE_ICON}" --out "${ICON_DIR}/icon_32x32@2x.png" > /dev/null 2>&1
    sips -z 128 128 "${BASE_ICON}" --out "${ICON_DIR}/icon_128x128.png" > /dev/null 2>&1
    sips -z 256 256 "${BASE_ICON}" --out "${ICON_DIR}/icon_128x128@2x.png" > /dev/null 2>&1
    sips -z 256 256 "${BASE_ICON}" --out "${ICON_DIR}/icon_256x256.png" > /dev/null 2>&1
    sips -z 512 512 "${BASE_ICON}" --out "${ICON_DIR}/icon_256x256@2x.png" > /dev/null 2>&1
    sips -z 512 512 "${BASE_ICON}" --out "${ICON_DIR}/icon_512x512.png" > /dev/null 2>&1
    sips -z 1024 1024 "${BASE_ICON}" --out "${ICON_DIR}/icon_512x512@2x.png" > /dev/null 2>&1
    echo "  ✓ Generated all icon sizes from custom PNG"

    # Optimize all generated PNGs
    if command -v pngquant &> /dev/null && command -v optipng &> /dev/null; then
        echo "  🔧 Optimizing icon files..."
        for png in "${ICON_DIR}"/*.png; do
            pngquant --quality=85-95 --speed 1 --force "$png" --output "$png" 2>/dev/null
            optipng -quiet -o7 "$png" 2>/dev/null
        done
        echo "  ✓ Optimized all icon sizes"
    fi
else
    echo "⚠ No custom icon found, generating default..."
    create_icon 16 "${ICON_DIR}/icon_16x16.png"
    create_icon 32 "${ICON_DIR}/icon_16x16@2x.png"
    create_icon 32 "${ICON_DIR}/icon_32x32.png"
    create_icon 64 "${ICON_DIR}/icon_32x32@2x.png"
    create_icon 128 "${ICON_DIR}/icon_128x128.png"
    create_icon 256 "${ICON_DIR}/icon_128x128@2x.png"
    create_icon 256 "${ICON_DIR}/icon_256x256.png"
    create_icon 512 "${ICON_DIR}/icon_256x256@2x.png"
    create_icon 512 "${ICON_DIR}/icon_512x512.png"
    create_icon 1024 "${ICON_DIR}/icon_512x512@2x.png"
fi

# Convert iconset to .icns
echo "📦 Converting to .icns format..."
iconutil -c icns "${ICON_DIR}" -o "${OUTPUT_ICON}"

echo "🧹 Cleaning up temporary files..."
rm -rf "${ICON_DIR}"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ Icon created successfully!"
echo "   ${OUTPUT_ICON}"
echo ""
echo "💡 To customize:"
echo "   1. Design your icon and export at 1024x1024px"
echo "   2. Save as assets/icon-1024.png"
echo "   3. Run this script again"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
