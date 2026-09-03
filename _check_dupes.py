import re
f = r'D:\Projects\moto-di-go\motodi-go-mobile\lib\core\l10n\app_texts.dart'
with open(f, 'r', encoding='utf-8') as fh:
    lines = fh.readlines()

keys = {}
for i, line in enumerate(lines, 1):
    # Match 'key': or "key":
    m = re.match(r'''^\s+(['"])(.*?)\1\s*:''', line)
    if m:
        key = m.group(2)
        if key in keys:
            print(f"DUPE line {i}: '{key}' (first at line {keys[key]})")
        else:
            keys[key] = i
