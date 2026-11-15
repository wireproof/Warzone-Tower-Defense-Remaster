#!/bin/sh
# Rebuild the 2x field and 8x vehicle experiment from the preserved v0.2.0 SWF.
# Usage: JAVA=/path/to/java FFDEC=/path/to/ffdec.jar ./tools/build_visual_swf.sh /new/output-directory
set -eu
[ "$#" -eq 1 ] || { echo 'Pass a new output directory' >&2; exit 2; }
: "${JAVA:?Set JAVA to the JDK java executable}"
: "${FFDEC:?Set FFDEC to the JPEXS ffdec.jar path}"
ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
OUT=$1
[ ! -e "$OUT" ] || { echo 'Output path already exists' >&2; exit 2; }
mkdir -p "$OUT"
"$JAVA" -jar "$FFDEC" -replace "$ROOT/Research/patch/warzone-visual-v1.swf" "$OUT/field-2x.swf" 62 "$ROOT/Assets/Remaster/Field/grass-2x.png" 17 "$ROOT/Assets/Remaster/Field/metal-2x.png" com.game.grid.GameGrid "$ROOT/Research/visual-hd/GameGrid.as"
"$JAVA" -jar "$FFDEC" -replace "$OUT/field-2x.swf" "$OUT/vehicles-unadjusted.swf" 644 "$ROOT/Assets/Remaster/Units/Runtime/644.png" 649 "$ROOT/Assets/Remaster/Units/Runtime/649.png" 653 "$ROOT/Assets/Remaster/Units/Runtime/653.png" 658 "$ROOT/Assets/Remaster/Units/Runtime/658.png" 663 "$ROOT/Assets/Remaster/Units/Runtime/663.png"
"$JAVA" -jar "$FFDEC" -swf2xml "$OUT/vehicles-unadjusted.swf" "$OUT/source.xml"
python3 "$ROOT/tools/adjust_sprite_matrices.py" "$OUT/source.xml" "$OUT/adjusted.xml"
"$JAVA" -jar "$FFDEC" -xml2swf "$OUT/adjusted.xml" "$OUT/roundtrip.swf"
python3 "$ROOT/tools/transplant_swf_shapes.py" "$OUT/vehicles-unadjusted.swf" "$OUT/roundtrip.swf" "$OUT/warzone-hd.swf"

"$JAVA" -jar "$FFDEC" -replace "$OUT/warzone-hd.swf" "$OUT/title-unadjusted.swf" 287 "$ROOT/Assets/Remaster/Menu/title-2x.png"
"$JAVA" -jar "$FFDEC" -swf2xml "$OUT/title-unadjusted.swf" "$OUT/title.xml"
python3 "$ROOT/tools/adjust_title_matrix.py" "$OUT/title.xml" "$OUT/title-adjusted.xml"
"$JAVA" -jar "$FFDEC" -xml2swf "$OUT/title-adjusted.xml" "$OUT/title-roundtrip.swf"
python3 "$ROOT/tools/transplant_swf_shapes.py" "$OUT/title-unadjusted.swf" "$OUT/title-roundtrip.swf" "$OUT/warzone-hd-title.swf" 288
