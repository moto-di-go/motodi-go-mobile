import re

f = r'D:\Projects\moto-di-go\motodi-go-mobile\lib\core\l10n\app_texts.dart'
with open(f, 'r', encoding='utf-8') as fh:
    lines = fh.readlines()

# Find all keys and their first occurrence line
keys_first = {}
dupes = set()
for i, line in enumerate(lines):
    m = re.match(r'''^\s+(['"])(.*?)\1\s*:''', line)
    if m:
        key = m.group(2)
        if key in keys_first:
            dupes.add(i)
            # If multi-line value (next line starts with spaces and quote), mark that too
            if i + 1 < len(lines) and re.match(r'^\s+\'', lines[i+1]):
                dupes.add(i + 1)
        else:
            keys_first[key] = i

# Remove duplicate lines
new_lines = [line for i, line in enumerate(lines) if i not in dupes]

with open(f, 'w', encoding='utf-8') as fh:
    fh.writelines(new_lines)

print(f"Removed {len(dupes)} duplicate lines")
for d in sorted(dupes):
    print(f"  Line {d+1}: {lines[d].strip()[:60]}")
