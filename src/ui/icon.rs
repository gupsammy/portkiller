use anyhow::{Result, anyhow};
use png::Decoder;
use tray_icon::Icon;

// Embed both icon variants at compile time
// Filled = active (ports listening), Outline = inactive (no ports)
static ICON_FILLED: &[u8] = include_bytes!("../../assets/menubar-icon-filled@2x.png");
static ICON_OUTLINE: &[u8] = include_bytes!("../../assets/menubar-icon-outline@2x.png");

/// Icon variant for different states
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum IconVariant {
    /// Outline arrows - no active ports
    Inactive,
    /// Filled arrows - ports are active
    Active,
}

/// Create a template icon for the menu bar.
/// Loads the appropriate icon variant from embedded PNG.
/// macOS automatically adapts the color based on menu bar appearance.
pub fn create_template_icon(variant: IconVariant) -> Result<Icon> {
    let png_data = match variant {
        IconVariant::Inactive => ICON_OUTLINE,
        IconVariant::Active => ICON_FILLED,
    };
    load_png_icon(png_data)
}

fn load_png_icon(png_data: &[u8]) -> Result<Icon> {
    let decoder = Decoder::new(png_data);
    let mut reader = decoder
        .read_info()
        .map_err(|e| anyhow!("failed to read PNG header: {e}"))?;

    let mut buf = vec![0; reader.output_buffer_size()];
    let info = reader
        .next_frame(&mut buf)
        .map_err(|e| anyhow!("failed to decode PNG: {e}"))?;

    let width = info.width;
    let height = info.height;

    // Convert to RGBA if needed
    let rgba = match info.color_type {
        png::ColorType::Rgba => buf[..info.buffer_size()].to_vec(),
        png::ColorType::Rgb => {
            let mut rgba = Vec::with_capacity((width * height * 4) as usize);
            for chunk in buf[..info.buffer_size()].chunks(3) {
                rgba.extend_from_slice(chunk);
                rgba.push(255);
            }
            rgba
        }
        png::ColorType::GrayscaleAlpha => {
            let mut rgba = Vec::with_capacity((width * height * 4) as usize);
            for chunk in buf[..info.buffer_size()].chunks(2) {
                let gray = chunk[0];
                let alpha = chunk[1];
                rgba.extend_from_slice(&[gray, gray, gray, alpha]);
            }
            rgba
        }
        png::ColorType::Grayscale => {
            let mut rgba = Vec::with_capacity((width * height * 4) as usize);
            for &gray in &buf[..info.buffer_size()] {
                rgba.extend_from_slice(&[gray, gray, gray, 255]);
            }
            rgba
        }
        png::ColorType::Indexed => {
            return Err(anyhow!("indexed PNG not supported for menu bar icon"));
        }
    };

    Icon::from_rgba(rgba, width, height).map_err(|e| anyhow!("failed to create icon: {e}"))
}
