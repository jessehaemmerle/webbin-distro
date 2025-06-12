#!/usr/bin/env python3

"""
Modern gradient wallpaper generator for Sway
Creates beautiful gradient wallpapers programmatically
"""

from PIL import Image, ImageDraw
import colorsys
import random
import os

def create_gradient_wallpaper(width=1920, height=1080, filename="modern-gradient.jpg"):
    """Create a modern gradient wallpaper"""
    
    # Modern color schemes
    color_schemes = [
        # Catppuccin inspired
        [(30, 30, 46), (49, 50, 68), (137, 180, 250)],  # Dark blue
        [(30, 30, 46), (49, 50, 68), (166, 227, 161)],  # Dark green
        [(30, 30, 46), (49, 50, 68), (245, 194, 231)],  # Dark pink
        [(30, 30, 46), (49, 50, 68), (249, 226, 175)],  # Dark yellow
        
        # Modern tech gradients
        [(13, 13, 35), (46, 16, 101), (99, 102, 241)],   # Purple tech
        [(0, 0, 0), (30, 30, 30), (60, 60, 60)],         # Monochrome
        [(15, 23, 42), (30, 41, 59), (71, 85, 105)],     # Slate
        [(17, 24, 39), (31, 41, 55), (75, 85, 99)],      # Gray
    ]
    
    # Choose a random color scheme
    colors = random.choice(color_schemes)
    
    # Create image
    image = Image.new('RGB', (width, height))
    draw = ImageDraw.Draw(image)
    
    # Create diagonal gradient
    for y in range(height):
        for x in range(width):
            # Calculate position in gradient (0.0 to 1.0)
            distance = ((x / width) + (y / height)) / 2
            
            # Interpolate colors
            if distance < 0.5:
                # First half: color0 to color1
                factor = distance * 2
                r = int(colors[0][0] * (1 - factor) + colors[1][0] * factor)
                g = int(colors[0][1] * (1 - factor) + colors[1][1] * factor)
                b = int(colors[0][2] * (1 - factor) + colors[1][2] * factor)
            else:
                # Second half: color1 to color2
                factor = (distance - 0.5) * 2
                r = int(colors[1][0] * (1 - factor) + colors[2][0] * factor)
                g = int(colors[1][1] * (1 - factor) + colors[2][1] * factor)
                b = int(colors[1][2] * (1 - factor) + colors[2][2] * factor)
            
            # Add some noise for texture
            noise = random.randint(-5, 5)
            r = max(0, min(255, r + noise))
            g = max(0, min(255, g + noise))
            b = max(0, min(255, b + noise))
            
            image.putpixel((x, y), (r, g, b))
    
    # Add subtle geometric shapes for modern look
    overlay = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    overlay_draw = ImageDraw.Draw(overlay)
    
    # Add some subtle circles
    for _ in range(3):
        x = random.randint(0, width)
        y = random.randint(0, height)
        radius = random.randint(100, 300)
        color = (*colors[2], 20)  # Very transparent
        
        overlay_draw.ellipse([x-radius, y-radius, x+radius, y+radius], 
                           fill=color, outline=None)
    
    # Composite the overlay
    image = Image.alpha_composite(image.convert('RGBA'), overlay)
    image = image.convert('RGB')
    
    # Save the image
    image.save(filename, 'JPEG', quality=95)
    print(f"Generated wallpaper: {filename}")


def main():
    """Generate wallpaper and save to user directory"""
    wallpaper_dir = os.path.expanduser("~/.config/sway/wallpapers")
    os.makedirs(wallpaper_dir, exist_ok=True)
    
    wallpaper_path = os.path.join(wallpaper_dir, "modern-gradient.jpg")
    
    # Generate different resolutions
    resolutions = [
        (1920, 1080),  # Full HD
        (2560, 1440),  # 2K
        (3840, 2160),  # 4K
    ]
    
    for width, height in resolutions:
        filename = os.path.join(wallpaper_dir, f"modern-gradient-{width}x{height}.jpg")
        create_gradient_wallpaper(width, height, filename)
    
    # Create a symlink to the most common resolution
    default_path = os.path.join(wallpaper_dir, "modern-gradient.jpg")
    if os.path.exists(default_path):
        os.remove(default_path)
    os.symlink(f"modern-gradient-1920x1080.jpg", default_path)


if __name__ == "__main__":
    main()
