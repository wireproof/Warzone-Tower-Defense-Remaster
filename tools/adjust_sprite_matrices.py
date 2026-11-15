#!/usr/bin/env python3
"""Adjust image fill matrices after replacing five SWF bitmaps at 8x size.

Usage: python3 adjust_sprite_matrices.py input.xml output.xml
The FFDec XML must already contain the resized images. Reject unexpected or
ambiguous fills instead of silently changing other game data.
"""
import re
import sys
from pathlib import Path

if len(sys.argv) != 3:
    raise SystemExit(__doc__)
text = Path(sys.argv[1]).read_text()
for bitmap_id in (644, 649, 653, 658, 663):
    pattern = r'(<item type="FILLSTYLE" bitmapId="' + str(bitmap_id) + r'"[^>]*>\s*<bitmapMatrix\b[^>]*/>)'
    def scale(match):
        matrix = match.group(1)
        if 'hasRotate="false"' not in matrix or 'hasScale="true"' not in matrix:
            raise ValueError(f"Unexpected transform for bitmap {bitmap_id}")
        for key in ("scaleX", "scaleY"):
            matrix, count = re.subn(key + r'="([^"]+)"', lambda m: key + '="' + str(float(m.group(1)) / 8) + '"', matrix)
            if count != 1:
                raise ValueError(f"Missing {key} for bitmap {bitmap_id}")
        return matrix
    text, count = re.subn(pattern, scale, text)
    if count != 1:
        raise ValueError(f"Expected one fill for bitmap {bitmap_id}, found {count}")
Path(sys.argv[2]).write_text(text)
