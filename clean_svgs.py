import os
import re

def clean_svg_files(directory):
    # Regex to find var(--name, #fallback)
    # It catches both fill="..." and stroke="..." attributes
    pattern = re.compile(r'var\(--[a-zA-Z0-9-]+\s*,\s*(#[a-fA-F0-9]{3,6})\)')
    
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith(".svg"):
                path = os.path.join(root, file)
                with open(path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                new_content = pattern.sub(r'\1', content)
                
                if new_content != content:
                    with open(path, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                    print(f"Cleaned: {path}")

if __name__ == "__main__":
    directories = [
        r"d:\Apps\Fit_Glow-main\lib\assets\images\profile",
        r"d:\Apps\Fit_Glow-main\lib\assets\icons"
    ]
    for directory in directories:
        if os.path.exists(directory):
            clean_svg_files(directory)
