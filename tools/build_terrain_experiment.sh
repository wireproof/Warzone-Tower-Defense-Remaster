#!/bin/zsh
# Rebuild the terrain experiment. The 2x source tiles affect the display only;
# map/pathing data and the grid's alpha-block collision mask remain untouched.
set -eu
: ${JAVA:?Set JAVA to a JDK java executable}
: ${FFDEC:?Set FFDEC to the JPEXS ffdec.jar path}
(( $# == 1 )) || { print -u2 'Pass a new output directory'; exit 2; }
root=${0:A:h:h}
out=$1
[[ ! -e $out ]] || { print -u2 'Output already exists'; exit 2; }
mkdir -p "$out"
swift "$root/tools/remaster_terrain.swift" "$root/Research/export/images" "$root/Assets/Remaster/Terrain/granite-source.png" "$out/tiles"
args=()
for id in {18..24} {28..46} {56..58} {69..76}; do args+=("$id" "$out/tiles/$id.png"); done
args+=(com.game.grid.GameGrid "$root/Research/terrain-pass/GameGrid-2x-obstacles.as")
"$JAVA" -jar "$FFDEC" -replace "$root/Research/visual-hd/warzone-hd-title.swf" "$out/warzone-terrain-2x.swf" "${args[@]}"
