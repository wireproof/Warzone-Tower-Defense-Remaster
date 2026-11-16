# Warzone Tower Defense Remaster

Experimental iOS compatibility build of Warzone Tower Defense, based on the supplied Flash game and running locally in Ruffle. This is a work in progress, not a completed cross-platform remaster. Current test: **0.3.3 (build 9)**, bundle identifier `com.wireproof.warzonetd`, iOS 16 or later, iPhone and iPad.

## Current state

The wrapper runs a patched copy of the game offline, with a touch bridge and single-placement tower drag behavior. The visual pass includes a 2× battlefield bitmap buffer and textures, five redrawn enemy bitmap assets, a refreshed title image, and the custom app icon. Most original towers, obstacles, interface, effects and gameplay remain in place; further high-resolution work is needed. External navigation and network access are blocked, so legacy online scores are unavailable.

Build 9 was installed on the intended iPhone and iPad without launching. Earlier builds had simulator testing and user-confirmed touch improvements, but build 7 physical-device runtime, visuals and performance have not been verified. macOS and Windows ports are not yet available. Screen layouts, levels, enemies and effects have not all been tested.

## Build and test

Open `WarzoneTD.xcodeproj` in Xcode, select your own Apple development team and a compatible iOS device, and build. The project can also be regenerated from `project.yml` with XcodeGen. A recipient must supply their own signing identity and provisioning. The release IPA is unsigned and cannot be installed directly without signing.

`Original/` contains the supplied SWF; `Research/export/` contains recovered assets and decompiled material, and `Research/patch/` and `Research/visual-hd/` contain patch and visual research. `Assets/`, `app/`, `tools/` and `tests/` contain the art, wrapper, build helpers and checks. The bundled Ruffle license is in `app/Resources/Web/RUFFLE-LICENSE.md`. Decompiled code is approximate and must be checked against game behavior.

The supplied original SWF has SHA-256 `0b72ae56bf088cb417cc9feb44092f27c94d7e41fde1039595121e8b7f83e9e8`; the current modified game SWF has SHA-256 `d4a1a36248d25c79edb100b26745a6e08589bad5a7a8825b491bfa474db67087`.

## Background playback update

Build 8 adds lifecycle handling to pause the Ruffle timeline and suspend audio when the app becomes inactive or the screen is locked. Local lifecycle and touch checks passed; physical background-audio testing remains pending. The battlefield graphics experiment under `Research/visual-hd/` is not included in the app; more visual remaster work is needed.

## Terrain graphics update

Build 9 replaces 37 original obstacle tiles with higher-resolution versions using the original shapes and generated stone detail. The simulator reached wave two and a scripted placement check produced two towers with the expected credit deduction. One earlier simulator run displayed a Ruffle error; its cause is unknown and later terrain runs reached the battlefield. Other maps, physical-device performance, touch and appearance need testing. The app was installed on both target devices without launching.
