#!/bin/bash
set -e

# Create menu bar icons for PortKiller
# Resizes the source icons to menu bar sizes (22x22 and 44x44)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ASSETS_DIR="${PROJECT_DIR}/assets"

OUTLINE_SRC="${ASSETS_DIR}/menu-icon-outline.png"
FILLED_SRC="${ASSETS_DIR}/menu-icon-filled.png"

echo "Creating menu bar icons..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

for src in "$OUTLINE_SRC" "$FILLED_SRC"; do
    if [ ! -f "$src" ]; then
        echo "Error: Source icon not found at $src"
        exit 1
    fi
done

# Check for ImageMagick
if ! command -v magick &> /dev/null && ! command -v convert &> /dev/null; then
    echo "Error: ImageMagick is required. Install with: brew install imagemagick"
    exit 1
fi

CMD="magick"
if ! command -v magick &> /dev/null; then
    CMD="convert"
fi

echo "Generating outline icons (inactive state)..."
$CMD "$OUTLINE_SRC" -resize 22x22 PNG32:"${ASSETS_DIR}/menubar-icon-outline.png"
echo "  ✓ menubar-icon-outline.png (22x22)"
$CMD "$OUTLINE_SRC" -resize 44x44 PNG32:"${ASSETS_DIR}/menubar-icon-outline@2x.png"
echo "  ✓ menubar-icon-outline@2x.png (44x44)"

echo "Generating filled icons (active state)..."
$CMD "$FILLED_SRC" -resize 22x22 PNG32:"${ASSETS_DIR}/menubar-icon-filled.png"
echo "  ✓ menubar-icon-filled.png (22x22)"
$CMD "$FILLED_SRC" -resize 44x44 PNG32:"${ASSETS_DIR}/menubar-icon-filled@2x.png"
echo "  ✓ menubar-icon-filled@2x.png (44x44)"

# Optimize with optipng
if command -v optipng &> /dev/null; then
    echo "Optimizing..."
    optipng -quiet -o7 "${ASSETS_DIR}/menubar-icon-outline.png" 2>/dev/null || true
    optipng -quiet -o7 "${ASSETS_DIR}/menubar-icon-outline@2x.png" 2>/dev/null || true
    optipng -quiet -o7 "${ASSETS_DIR}/menubar-icon-filled.png" 2>/dev/null || true
    optipng -quiet -o7 "${ASSETS_DIR}/menubar-icon-filled@2x.png" 2>/dev/null || true
    echo "  ✓ Optimized with optipng"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Menu bar icons created:"
echo "  Outline (inactive): menubar-icon-outline.png, menubar-icon-outline@2x.png"
echo "  Filled (active):    menubar-icon-filled.png, menubar-icon-filled@2x.png"
echo ""
echo "These are embedded in the binary at compile time."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
