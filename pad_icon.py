import sys
from PIL import Image

def pad_image():
    try:
        img_path = 'assets/icon/app_icon_v3.png'
        out_path = 'assets/icon/app_icon_adaptive_foreground.png'
        
        img = Image.open(img_path).convert("RGBA")
        width, height = img.size
        
        # Scale down to 62% to fit perfectly within Android's adaptive icon safe zone (72/108 = 66%, 62% gives extra safety margin)
        new_w = int(width * 0.62)
        new_h = int(height * 0.62)
        
        resized_img = img.resize((new_w, new_h), Image.Resampling.LANCZOS)
        
        # Create new transparent image of original size
        new_img = Image.new("RGBA", (width, height), (0, 0, 0, 0))
        
        # Paste resized image in the center
        offset_x = (width - new_w) // 2
        offset_y = (height - new_h) // 2
        new_img.paste(resized_img, (offset_x, offset_y), resized_img)
        
        new_img.save(out_path, "PNG")
        print("Successfully created padded adaptive icon foreground at:", out_path)
    except Exception as e:
        print("Error padding image:", e)
        sys.exit(1)

if __name__ == '__main__':
    pad_image()
