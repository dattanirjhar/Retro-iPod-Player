# iPlayr

A faithful iPod classic recreation for iOS, built entirely in SwiftUI on top of Apple Music.

Not an iPod-*inspired* player: the click wheel drives every interaction, the menu keeps its
split-screen artwork pane, and the hardware is drawn live from twenty fixed theme presets.

[![Platform](https://img.shields.io/badge/platform-iOS%2017%2B-lightgrey)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-6.0-orange)](https://swift.org)

## Features

- **Click wheel.** Rotate your thumb to scroll, with selection haptics and the original click sound.
  MENU goes back one screen; hold it to jump to the main menu. Hold previous or next to seek with
  acceleration. The hit map is a fixed centre circle and four 90° sectors, identical in every theme.
- **Split-screen menus.** The artwork pane on the right slowly pans through your album covers.
- **Cover Flow.** Flick through your albums in 3D and flip a cover to see its tracks, inside the iPod
  screen or as a full-phone immersive view.
- **Now Playing.** Artwork, track details, queue position, progress with elapsed and remaining time,
  an explicit Volume / Seek wheel mode, transport buttons, and an optional artwork-tinted atmosphere.
- **Your Apple Music library.** Albums, artists, playlists, songs, genres and composers, with
  alphabetical or recently-added sorting, shuffle songs and shuffle albums.
- **Configurable menus and settings.** Choose library shortcuts, adjust brightness, and toggle
  haptics and the clicker.

## Appearance

<img width="624" height="750" alt="image" src="https://github.com/user-attachments/assets/4af287d8-22c5-4576-b218-0caccf18ad75" style="display: block; margin: 0 auto;/>


Two independent choices under Settings › App Settings:

- **Theme** picks one of 20 presets that set the body, click wheel, wheel style, finish, label
  colour, accent (selected row and progress) and atmosphere level: six Classic, four Mini, six Nano
  and four Modern. Scrolling the picker previews a theme live; the centre button confirms; MENU
  cancels.
- **Mode** is Dark or Light and changes only the screen surfaces, text, divider and progress track.
  It never touches the hardware.

Every constant lives in `iPlayr/iPlayr/Core/Theme/ThemeCore/` and is checked by tests for WCAG
contrast across all 40 theme × mode combinations. `design/contact-dark.png` and
`design/contact-light.png` show all twenty themes in each mode.

## Requirements

- Xcode 16 or later (an iOS 27 SDK to run on current devices)
- iOS 17.0+
- An active Apple Music subscription
- A physical device is recommended; music playback and battery reporting are limited in the simulator

## Getting started

```bash
git clone <your-remote-url> iPlayr
cd iPlayr
open iPlayr/iPlayr.xcodeproj
```

Set your own signing team and bundle identifier, enable the MusicKit app service on the App ID in the
Developer portal, then run. On first launch the app asks for Apple Music access from the Sign In menu.

## Verifying the theme logic without a Mac

The theme constants, colour maths, selection and migration logic, and wheel geometry are Foundation-only
and build as a SwiftPM package:

```bash
cd ThemeCore && swift build && swift test
```

On a machine without Swift, the official image works the same way (mount the repository root so the
package's symlinked sources resolve):

```bash
docker run --rm -v "$PWD":/repo -w /repo/ThemeCore swift:6.0-jammy swift test
```

`scripts/contact_sheets.py` regenerates the two contact sheets from the Swift sources.

## Project documents

- `THEME_MIGRATION_STATUS.md`: per-item status of the Theme + Mode work.
- `PHASE2_MAC_HANDOFF.md`: build, test, screenshot and device-check steps for the Mac phase.
- `BETA_TEST_LOG.md`: template for logging issues found on the device.

## Contributing

Issues and pull requests are welcome. Please keep changes focused and match the surrounding style.
