# iPod-Playr (still in dev)

A faithful iPod classic recreation for iOS, built entirely in SwiftUI on top of Apple Music.

Not an iPod-*inspired* player: the click wheel drives every interaction, the menu keeps its
split-screen artwork pane, and the hardware is drawn live from 21 theme presets.

[![Platform](https://img.shields.io/badge/platform-iOS%2017%2B-lightgrey)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-6.0-orange)](https://swift.org)

## Features

- **Click wheel.** Rotate your thumb to scroll, with selection haptics and the original click sound.
  The double-bar Menu control goes back one screen; hold it to jump to the main menu.
  Tap previous or next to skip tracks; use Now Playing's Seek wheel mode to scrub.
  The hit map is identical in every theme.
- **Split-screen menus.** The artwork pane on the right slowly pans through your album covers.
- **Cover Flow.** Flick through your albums in 3D and open an album's scrolling track list, inside the
  iPod screen or as a full-phone immersive view. Immersive playback opens normal Now Playing;
  MENU restores the album/list you left.
- **Now Playing.** Artwork, track details, queue position, progress with elapsed and remaining time,
  an explicit Volume / Seek wheel mode (seek commits once the wheel settles, audio never pauses),
  transport buttons, and an optional artwork-tinted atmosphere. Hold Play/Pause on any screen to
  jump here; MENU takes you back to the row you left.
- **Queue.** Hold SELECT on Now Playing to see the queue and jump to any entry. Hold SELECT on any
  song row for Play Now, Play Next or Add to End of Queue.
- **Your Apple Music library.** Albums, artists, playlists, songs, genres and composers, with
  alphabetical or recently-added sorting, shuffle songs and shuffle albums.
- **Configurable menus and settings.** Choose library shortcuts, adjust brightness, and toggle
  haptics and the clicker.
- **About.** App/build information, library totals, device details and inspiration, navigable with
  the wheel, SELECT or the Next control.

## Appearance

<p align="center">
  <img width="624" height="750" alt="image" src="https://github.com/user-attachments/assets/4af287d8-22c5-4576-b218-0caccf18ad75">
</p>


Two independent choices under Settings › App Settings:

- **Theme** picks one of 21 presets that set the body, click wheel, wheel style, finish, label
  colour, accent (selected row and progress) and atmosphere level: six Classic, four Mini, six Nano
  and five Modern. Scrolling the picker previews a theme live; the centre button confirms; MENU
  cancels.
- **Mode** is Dark or Light and changes only the screen surfaces, text, divider and progress track.
  It never touches the hardware.

Every constant lives in `iPlayr/iPlayr/Core/Theme/ThemeCore/` and is checked by tests for WCAG
contrast across all 42 theme × mode combinations. `design/contact-dark.png` and
`design/contact-light.png` show all 21 themes in each mode as Pillow approximations. Frosted glyph
contrast checks cover the opaque accessibility fallback; bare glyphs require device optical review.
Ceramic has a cool white satin body, a smooth flush wheel and soft chamfer highlights. Porcelain
has a warm glazed body, recessed annular channels, fine metallic inlays and engraved label details.
Frosted keeps a dark neutral body and artwork color behind its controls, with native glass on iOS
26+, a system-material fallback on earlier versions, and bare symbols with a soft shadow.
Reduce Transparency or Increase Contrast restores opaque controls and label backings. Clear has
been retired; saved Clear selections migrate to Frosted without changing Dark/Light mode.
Stored Ceramic, Porcelain and Frosted IDs remain compatible.
Modern Album Glow uses broad artwork-derived light inside Now Playing at 80% preferred intensity,
retaining its violet hardware. Frosted keeps a neutral screen and shows blurred artwork through
the wheel at 80% opacity with a 115% artwork luminance multiplier. Missing artwork leaves
Frosted neutral and gives Album Glow a violet fallback; contrast protection and accessibility
preferences take priority.

## Requirements

- Xcode 26 or later (an iOS 27 SDK to run on current devices)
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

## Unsigned IPA for manual SideStore testing

With full Xcode installed and selected as the active developer directory:

```bash
bash scripts/build_ipa.sh
```

This builds Release for physical iPhones and writes `DerivedData/Artifacts/iPod-Playr-SideStore.ipa`.
The archive excludes macOS metadata sidecars so SideStore sees exactly one app bundle in Payload.
SideStore signs the IPA during manual installation. The build requires no local signing account;
successful installation does not establish MusicKit service access or runtime correctness.
No simulator or automated phone installation is used. Run the Foundation-only tests on the Mac
with `swift test --package-path ThemeCore`; record phone observations in `BETA_TEST_LOG.md`.

Latest manual beta: **1.6 (7)**, `DerivedData/Artifacts/iPod-Playr-SideStore-1.6.ipa`.
Only this IPA is retained. See the [beta checklist and verification](design/beta/2026-10-17/README.md).
This replacement includes Bold 3.25 pt Menu bars; the original 1.5 (5) candidate used 1.75 pt bars.

Release versions follow **1.2 (build 2) → 1.3 (build 3) → 1.4 (build 4) → 1.5 (build 5)**.
The Bold update was initially packaged as 1.5 (6), then corrected to **1.6 (7)** at the user’s request.
New releases increment the minor version and build number; replacements increase the build number.
Next is **1.7 (build 8)**.
Earlier releases 1.2/1.3 originally embedded marketing version 1.0; historical filenames, metadata
and verification logs retain those original values.

## Project documents

- `CHANGELOG.md`: release history and an Unreleased section for ongoing development.
- `THEME_MIGRATION_STATUS.md`: per-item status of the Theme + Mode work.
- `HANDOFF_2026-10-16.md`: remote updates, local Mac follow-up fixes, and remaining device checks.
- `PHASE2_MAC_HANDOFF.md`: current prod-dev-team handoff, with implementation, build/test status, and acceptance checks.
- `BETA_TEST_LOG.md`: original device observations, remote-update review, follow-up fixes, selected designs and release verification.
- `design/beta/2026-10-16/logs/`: saved Mac test failure, passing 20-test run, Debug/Release iOS builds, and version 1.2 (2) IPA verification.
- `design/beta/2026-10-17/`: captured settings, current/historical beta checklists, 29-test results, Release analysis/build logs and IPA verification.
- `design/beta/2026-10-15/README.md`: saved screenshots, console/build logs, checksums and superseded plans.

## Inspiration

Inspired by iPodPlayer. iPod-Playr has been extensively reworked with its own theme system,
Cover Flow behavior, navigation refinements and playback controls, while retaining the underlying
SwiftUI and MusicKit foundation.

## Contributing

Issues and pull requests are welcome. Please keep changes focused and match the surrounding style.
Record user-visible changes under Unreleased in `CHANGELOG.md`; date and version that section when
packaging the next IPA, keeping device acceptance separate from build/test verification.
