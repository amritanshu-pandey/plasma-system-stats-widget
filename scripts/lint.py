#!/usr/bin/env python3
"""Run qmllint on the given files and fail on any warning.

Plasma provides i18n() and related functions at runtime, so qmllint reports
them as unqualified access. Those warnings are ignored.
"""

import json
import os
import shutil
import subprocess
import sys

CANDIDATES = ["/usr/lib64/qt6/bin/qmllint", "/usr/lib/qt6/bin/qmllint"]
TRANSLATION_FUNCTIONS = ("i18n(", "i18nc(", "i18np(", "i18ncp(")


def find_qmllint():
    found = os.environ.get("QMLLINT") or shutil.which("qmllint6") or shutil.which("qmllint")
    if found:
        return found
    for path in CANDIDATES:
        if os.path.exists(path):
            return path
    sys.exit("qmllint not found. Install the Qt 6 declarative development tools or set QMLLINT.")


def is_translation_call(path, warning):
    with open(path, encoding="utf-8") as f:
        source = f.read()
    return source[warning["charOffset"]:].startswith(TRANSLATION_FUNCTIONS)


def main(files):
    if not files:
        sys.exit("usage: lint.py FILE.qml...")
    import_dirs = sorted({os.path.dirname(os.path.abspath(f)) for f in files})
    command = [find_qmllint(), "--json", "-"]
    for directory in import_dirs:
        command += ["-I", directory]
    result = subprocess.run(command + files, capture_output=True, text=True)
    report = json.loads(result.stdout)

    problems = []
    for entry in report["files"]:
        for warning in entry["warnings"]:
            if warning["type"] == "info":
                continue
            if warning["id"] == "unqualified" and is_translation_call(entry["filename"], warning):
                continue
            name = os.path.relpath(entry["filename"])
            problems.append(f'{name}:{warning["line"]}:{warning["column"]}: {warning["message"]} [{warning["id"]}]')

    for problem in problems:
        print(problem)
    print(f"{len(problems)} problem(s) in {len(files)} file(s)")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
