from svglib.svglib import svg2rlg
from reportlab.graphics import renderPM

# Load SVG file
drawing = svg2rlg("assets/logo_source.svg")

# Save as PNG
renderPM.drawToFile(drawing, "assets/splash_logo.png", fmt="PNG")
print("Successfully converted SVG to PNG at assets/splash_logo.png")
