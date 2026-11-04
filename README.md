# Legend Reborn Android

An original Godot 4.3 mobile prototype inspired by turn-based trading-card duels. This is not the original Yu-Gi-Oh! The Legend Reborn game and contains no proprietary game code or assets.

## Project contents

- `Main.tscn`: main scene
- `scripts/main.gd`: duel logic and generated 40-card training deck
- `cards.json`: sample card-data format
- `project.godot`: Godot 4.3 project settings
- `export_presets.cfg`: Android ARM64 export preset
- `.github/workflows/android-release.yml`: cloud APK build

## Build an APK

Every push to `main` runs the Android build workflow. It installs Android SDK packages, downloads Godot 4.3 and its export templates, validates the project files, imports the project, exports a signed ARM64 APK, and uploads it as the `LegendReborn-Android-APK` workflow artifact.

To download it, open the repository's **Actions** tab, select the latest successful **Build Android APK** run, and download the artifact.

The current workflow creates a temporary signing key for each build. This is suitable for testing, but APKs from separate runs will not share the same signing identity and therefore cannot be installed as in-place updates over one another. A persistent private keystore and GitHub Actions secrets should be configured before distributing updates.

## Device target

- Package ID: `org.synoizu2wq.legendrebornandroid`
- Architecture: ARM64
- Renderer: Godot Compatibility (OpenGL)
- Internet permission: disabled
- Version: 1.0.0 (version code 1)

## Prototype scope

The current prototype has simplified combat, one monster per side, a generated training deck, and basic draw/summon/attack/end-turn actions. It does not yet implement full official trading-card rules, card effects, deck editing, collection management, animations, sound, online play, or original game assets.

The APK must pass the GitHub Actions export and artifact-upload steps before it is considered built. Device installation and gameplay still need to be tested on the Samsung Galaxy A04.
