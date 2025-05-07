import os
import re
from datetime import datetime
import pytz

def fix_lastmod(filepath):
    try:
        with open(filepath, 'r+', encoding='utf-8') as f:
            content = f.readlines()
            f.seek(0)
            updated_content = []
            in_front_matter = False
            front_matter_lines = []

            for line in content:
                if line.strip() == '---':
                    if in_front_matter:
                        front_matter_lines.append(line)
                        in_front_matter = False
                    else:
                        in_front_matter = True
                        front_matter_lines.append(line)
                    updated_content.append(line)
                    continue

                if in_front_matter:
                    front_matter_lines.append(line)
                    if line.startswith('lastmod:'):
                        lastmod_value = line.split(':', 1)[1].strip()
                        # Regex to find duplicated timezone offsets
                        match = re.match(r'(.+)([+-]\d{2}:\d{2})([+-]\d{2}:\d{2})$', lastmod_value)
                        if match:
                            corrected_lastmod = f"lastmod: {match.group(1)}{match.group(2)}\n"
                            updated_content.append(corrected_lastmod)
                            print(f"Corrected lastmod in {filepath} from '{line.strip()}' to '{corrected_lastmod.strip()}'")
                        else:
                            updated_content.append(line)
                    else:
                        updated_content.append(line)
                else:
                    updated_content.append(line)

            f.writelines(updated_content)
            f.truncate()

    except Exception as e:
        print(f"Error processing {filepath}: {e}")

def process_posts(directory):
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith(('.markdown', '.md')):
                filepath = os.path.join(root, file)
                fix_lastmod(filepath)

if __name__ == "__main__":
    posts_directory = "content/posts"  # Adjust if your posts are in a different directory
    process_posts(posts_directory)
    print("Finished processing post files for duplicated timezone in lastmod.")