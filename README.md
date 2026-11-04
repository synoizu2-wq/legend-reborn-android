# Legend Reborn Android — source + cloud APK build

This is an original, small Godot 4.3 prototype inspired by turn-based trading-card duels.
It is **not** the original Yu-Gi-Oh! The Legend Reborn game and contains no proprietary
source code, card art, music, or original game assets.

## What this repository contains

- A playable starter duel prototype (`Main.tscn`, `scripts/main.gd`)
- 40 generated placeholder cards
- Android export preset targeting ARM64
- GitHub Actions workflow to build a signed Release APK in the cloud

## Important before running the workflow

1. Change this GitHub repository to **Private** before the first build. The first run
   generates a signing key and uploads it as a short-lived artifact so it can be saved
   as GitHub Actions secrets. Do not expose this artifact publicly.
2. The workflow uses Godot 4.3 and `barichello/godot-ci:4.3`, including Android export
   templates and Android SDK tooling.
3. Open the repository's **Actions** tab and run **Build signed Android Release APK**
   using **Run workflow** (or push a commit to `main`).

## First build: save the signing key for future updates

The first successful workflow run creates two artifacts:

- `LegendReborn-Android-Release`: the installable signed APK.
- `LegendReborn-Release-Signing-Material`: contains a Base64 keystore and credentials.

Download the signing-material artifact immediately and keep it private. In the repository,
go to **Settings → Secrets and variables → Actions → New repository secret** and create:

- `ANDROID_KEYSTORE_BASE64`: the full contents of `ANDROID_KEYSTORE_BASE64.txt`
- `ANDROID_KEY_ALIAS`: value of `ANDROID_KEY_ALIAS` in `signing-credentials.txt`
- `ANDROID_KEYSTORE_PASSWORD`: value of `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_PASSWORD`: value of `ANDROID_KEY_PASSWORD`

After saving all four secrets, future workflow runs reuse the same signing key. Do not
lose the keystore or passwords: Android will not allow an in-place update signed with a
different key. If you lose the key, users generally must uninstall the old app before
installing a newly signed build.

## Download the APK

After the workflow completes, open the workflow run in the **Actions** tab, scroll to
**Artifacts**, and download `LegendReborn-Android-Release`. Extract the APK and install it
on the Samsung Galaxy A04. Android may ask you to allow installation from that browser or
file manager.

## Build details

- Android package ID: `org.synoizu2wq.legendrebornandroid`
- Architecture: ARM64
- Renderer: Godot Compatibility (OpenGL)
- Internet permission: disabled
- Version: 1.0.0 (version code 1)

## Prototype limitations

This is a first gameplay prototype, not a faithful recreation. It currently has simplified
combat and one monster per side. It does not yet implement the complete official rules,
card effects, deck editor, collection, animations, sound, online play, or original game
content. The APK has not been built or device-tested yet; the workflow must run successfully
before an installable APK exists.

## Build source

The GitHub Actions workflow is `.github/workflows/android-release.yml`.
