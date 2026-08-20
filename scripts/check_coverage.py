#!/usr/bin/env python3
"""Fail CI when instrumented, testable Dart coverage is below the gate.

Mirrors codecov.yml ignores plus TESTING_POLICY.md: generated code, l10n,
UI pages/widgets, and datasources are not part of the unit-test budget.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

THRESHOLD = 60
LCOV_PATH = Path("coverage/lcov.info")

IGNORE_SUFFIXES = (
    ".g.dart",
    ".freezed.dart",
    ".config.dart",
    ".chopper.dart",
    "_figma_icons.dart",
    "_datasource.dart",
)
IGNORE_PATH_PARTS = (
    "/l10n/",
    "/presentation/pages/",
    "/presentation/widgets/",
    "/datasources/",
    "/features/example/",
)
IGNORE_FILE_ENDS = (
    "/lib/main.dart",
    "lib/main.dart",
    "/lib/routes/app_router.dart",
    "lib/routes/app_router.dart",
)


def ignored(source_file: str) -> bool:
    path = source_file.replace("\\", "/")
    name = path.rsplit("/", 1)[-1]
    if name.endswith(IGNORE_SUFFIXES):
        return True
    if any(part in path for part in IGNORE_PATH_PARTS):
        return True
    return any(path.endswith(end) for end in IGNORE_FILE_ENDS)


def main() -> int:
    if not LCOV_PATH.exists():
        print(f"Missing {LCOV_PATH}", file=sys.stderr)
        return 1

    content = LCOV_PATH.read_text(encoding="utf-8", errors="ignore")
    total = 0
    hit = 0
    for record in content.split("end_of_record"):
        match = re.search(r"^SF:(.*)$", record, re.M)
        if not match or ignored(match.group(1)):
            continue
        da = re.findall(r"DA:\d+,(\d+)", record)
        total += len(da)
        hit += sum(1 for value in da if value != "0")

    pct = hit * 100 // total if total else 0
    print(f"Coverage: {pct}% ({hit}/{total} lignes testables)")
    if pct < THRESHOLD:
        print(
            f"Seuil {THRESHOLD}% non atteint. "
            "Les pages/widgets, la l10n et le code généré sont exclus.",
            file=sys.stderr,
        )
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
