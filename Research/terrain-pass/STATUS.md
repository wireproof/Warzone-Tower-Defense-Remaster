# Terrain graphics pass

Version 0.3.3 build 9 candidate uses `warzone-terrain-2x-v3.swf`. Thirty-seven 17x17 obstacle bitmap tiles were rebuilt at 34x34 from their original silhouettes and shading with generated granite texture detail. GameGrid draws those 2x tiles at the original logical footprint. The alpha-block collision mask and map/pathing data are unchanged. The app's existing input and lifecycle bridge are unchanged.

Simulator validation used an iPad simulator and a test-only injected mouse-event sequence, not physical touch. The default green map reached wave two; two separate arsenal selections produced two towers and credits fell from 1000 to 500 despite an intervening field click. Screenshot: `ipad-simulator-v3-gameplay.png`. The original build 8 SWF also reached the battlefield in the same test harness. A prior cold run with the first terrain experiment displayed a Ruffle error once; later terrain runs reached the battlefield. Root cause is not established and the first error cannot be ruled out as an intermittent renderer issue. Other maps, physical input, physical visuals, audio and sustained performance have not been verified.

`tools/build_terrain_experiment.sh` regenerates the current tile treatment from the texture and source assets when JAVA and FFDEC are set. Previous variants are retained as experiments.
