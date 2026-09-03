import re

files = [
    r'D:\Projects\moto-di-go\motodi-go-mobile\lib\features\intercity\presentation\pages\search_pages.dart',
    r'D:\Projects\moto-di-go\motodi-go-mobile\lib\features\intercity\presentation\pages\booking_pages.dart',
    r'D:\Projects\moto-di-go\motodi-go-mobile\lib\features\intercity\presentation\pages\publish_pages.dart',
]

# Pattern: formatXxx(someExpr) -> formatXxx(someExpr, context: context)
# But NOT if already has context:
funcs = ['formatShortDate', 'formatDayMonth', 'formatDayMonthLong', 'formatWeekdayDate', 'formatRelativeDayTime']

for fpath in files:
    with open(fpath, 'r', encoding='utf-8') as fh:
        c = fh.read()
    
    for func in funcs:
        # Match func( ... ) where there's no 'context:' already
        # Simple approach: replace func(xxx) with func(xxx, context: context)
        # where xxx doesn't contain 'context:'
        pattern = re.compile(rf'({func}\()([^)]+?)(\))')
        def repl(m):
            args = m.group(2)
            if 'context:' in args:
                return m.group(0)
            return f'{m.group(1)}{args}, context: context{m.group(3)}'
        c = pattern.sub(repl, c)
    
    with open(fpath, 'w', encoding='utf-8') as fh:
        fh.write(c)
    print(f"Done {fpath.split(chr(92))[-1]}")
