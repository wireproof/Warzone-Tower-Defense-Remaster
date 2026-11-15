#!/usr/bin/env python3
"""Preserve title art placement after replacing its bitmap at double size."""
import re
import sys
from pathlib import Path
if len(sys.argv) != 3:
    raise SystemExit('Usage: adjust_title_matrix.py source.xml destination.xml')
s = Path(sys.argv[1]).read_text()
pattern = r'(<item type="FILLSTYLE" bitmapId="287"[^>]*>\s*<bitmapMatrix\b[^>]*/>)'
def fix(match):
    matrix = match.group(1)
    if 'hasRotate="false"' not in matrix or 'hasScale="true"' not in matrix:
        raise ValueError('Unexpected title transform')
    for key in ('scaleX', 'scaleY'):
        matrix, count = re.subn(key + r'="([^"]+)"', lambda m: key + '="' + str(float(m.group(1)) / 2) + '"', matrix)
        if count != 1:
            raise ValueError('Missing scale')
    return matrix
s, count = re.subn(pattern, fix, s)
if count != 1:
    raise ValueError('Expected one title fill')
Path(sys.argv[2]).write_text(s)
