# Beta handoff for prod-dev-team — 16 October 2026

> Current release: **1.4 (build 4)**. See [the current beta notes](design/beta/2026-10-17/README.md).
> Historical releases are now labeled **1.2 (build 2)** and **1.3 (build 3)**. Those original IPAs
> embedded version 1.0; their recorded metadata, filenames and logs remain unchanged. Earlier
> status and retained-artifact statements below describe their original dates.


> **17 October follow-up:** immersive Cover Flow now selects individual tracks, opens normal
> Now Playing, and preserves the album/list for MENU return. Denser album spacing, landscape label
> layout, status-bar contrast, and the 22-theme gallery are updated in source. Cover Flow uses the chosen
> 0.70 / 0.36 spacing. Ceramic, Engraved, Frosted and Clear are implemented, with artwork light behind
> both glass wheels at 75% Frosted / 50% Clear. Their LCD stays neutral. Album Glow now uses Ambient Screen
> at 80% preferred intensity, retaining violet hardware. All 28 tests (594 fixed contrast checks plus
> dynamic lighting checks), Release compilation and fresh Release analysis pass. Version **1.3 (3)**
> is packaged and verified; only this IPA is retained. Variant labels wrap and embedded track lists
> use the available area. Device acceptance remains pending; see `design/beta/2026-10-17/README.md`.

> **16 October Mac update:** the four beta fixes and later queue/seek/shortcut features compile
> successfully. Three follow-up fixes are committed in `4b188ef`; all 20 ThemeCore tests and the
> unsigned Debug iOS build pass. Release version 1.2 (2) is built and its IPA passes packaging
> checks; manual installation and device acceptance remain pending. See
> [the detailed log](BETA_TEST_LOG.md#mac-review-and-follow-up-fixes--16-october-2026) and
> [the updated technical handoff](HANDOFF_2026-10-16.md).

Prepared from the user's 15 October 2026 beta session on an iPhone 17 running iOS 27.0.1.
This is the current plan and acceptance checklist. It replaces the earlier Mac setup/simulator
plan and the empty device checklist. Their previous versions are preserved in the
[evidence archive](design/beta/2026-10-15/archive/).

## Direction from the user

**Original 15 October direction: document the findings, then apply the fixes the following day.**
No app code, layout, preferences, theme constants or IPA was changed while preparing that original
handoff. On 16 October, the user authorized fixing the three issues found during the Mac review;
the changes and verification are recorded in the latest log linked above.

The user reports that the rest of their tested use is working fine. Keep the next pass focused on
these four issues. Cover Flow is unusable enough that the user intends to deactivate or avoid it
while using the app. That is the user's temporary workaround; no feature flag or removal has been
implemented. The Immersive Mode setting changes presentation and does not disable Cover Flow itself.

## Current build and verification

- Latest source: `4b188ef`, including MAC-01 through MAC-03, plus the local build-number bump to 2.
  All 20 native Mac ThemeCore tests and unsigned Debug compilation for
  `generic/platform=iOS` pass. Only the existing App Intents metadata warning was emitted by Xcode.
- New candidate: `DerivedData/Artifacts/iPod-Playr-SideStore-1.0-2.ipa`, version 1.2 (2),
  unsigned Release for arm64 iPhoneOS, minimum iOS 17.0. Build and packaging checks passed;
  manual SideStore installation and device checks remain pending. The exact checksum and
  saved validation logs are in `BETA_TEST_LOG.md`.
- The candidate details below describe the **previous 15 October installed IPA**. Its saved
  archive and the duplicate unversioned 1.2 (2) IPA were deleted on 17 October at the user's
  request. Only `DerivedData/Artifacts/iPod-Playr-SideStore-1.0-2.ipa` remains for distribution.
- App version: 1.0 (1), built from baseline `679be9b` plus uncommitted Phase 2 fixes.
- Tools: Xcode 27.0 (27A266a), iOS 27.0 SDK, Apple silicon Mac on macOS 27.0.1.
- Device: iPhone 17, iOS 27.0.1; user manually signs/installs through SideStore with a free Apple ID.
- Delivered artifact: `DerivedData/Artifacts/iPod-Playr-SideStore.ipa`.
- Corrected IPA SHA-256: `7df9fbca27c8b23cd8914079addd5bbd9206b71df804296a570a003d1d0c8de3`.
- Earlier verification: 13 native Mac ThemeCore tests passed, including 540 contrast checks;
  Release iPhone compilation and Debug Analyze passed. These do not validate visual layout.
- The supplied screenshots establish that the app launched and reached populated app screens.
  The user reports other tested functionality working. This is not an itemized pass for every
  background playback, migration, accessibility or persistence scenario.
- The five iOS app-module tests still have no configured Xcode test target and were not run.
- No simulator testing or automated phone installation was performed. Continue using Mac tests
  plus manual phone installation/screenshots for this work.

## Issues to fix

### BETA-01 — Home heading must read iPod (P2)

**Observed:** The simulated screen's top-left home heading says `iPlayr` in the landscape and
portrait home screenshots.

**Requested:** Change that visible heading to exactly `iPod` in both orientations and all themes.
This request concerns the in-app heading; it does not request renaming Swift symbols, the project,
MusicKit identifiers, bundle identifiers or the repository. The installed display name is already iPod.

**Evidence:** [03 landscape](design/beta/2026-10-15/screenshots/03-home-landscape.jpeg),
[04 minimal portrait](design/beta/2026-10-15/screenshots/04-home-portrait-minimal.jpeg),
[05 classic portrait](design/beta/2026-10-15/screenshots/05-home-portrait-classic.jpeg).

**Code entry point:** `iPlayr/iPlayr/Screens/Home/HomeListView.swift`, the `StatusBar` title.

### BETA-02 — Cover Flow does not fit or align with its viewport (P1)

**User report:** Cover Flow is completely misaligned with Immersive Mode both **On and Off**.
Treat both presentations as affected, and test both portrait and landscape. This is a layout
failure, broader than the previously documented lack of tappable immersive track rows.

**Visible evidence:**

- [01 portrait](design/beta/2026-10-15/screenshots/01-coverflow-portrait.jpeg): the selected Sonny & Cher
  cover is displaced towards the right and cut off. Album text and the bottom Play control are
  also clipped at the right edge. The carousel is not centered in the visible viewport.
- [02 landscape](design/beta/2026-10-15/screenshots/02-coverflow-landscape.jpeg): the carousel is low
  in the viewport and the covers are cut off at the bottom. The album details and bottom controls
  are not visible in the captured frame. The exit control is visible near the upper right.

The exact Immersive Mode setting was not recorded per image. The full-phone controls suggest
an immersive presentation, but do not use that inference to dismiss the user's explicit report
that both settings fail. There is no separate screenshot conclusively labeled as the Off state.

**Reproduction for tomorrow:** Open Music → Cover Flow (or a configured Cover Flow shortcut).
Start in portrait, browse a few albums, then rotate. Repeat with Settings → App Settings →
Immersive Mode Off and On. Open Tracks and return to covers; start playback and return; exit to
the home menu. Record which state and orientation each screenshot shows.

**Expected:** The selected cover is centered and readable; titles and controls remain inside the
available viewport and safe areas. The embedded presentation stays within the simulated screen;
the immersive presentation fits the phone. Neighboring covers may intentionally extend beyond
carousel edges, but the selected cover and actionable controls must remain usable.

**Read-only code map / investigation leads (not diagnosed causes):**

- `Screens/CoverFlow/CoverFlowView.swift`: outer GeometryReader, carousel positioning, available
  content height, album info, immersive controls, and the scaled/blurred backdrop.
- `Screens/CoverFlow/AlbumCover.swift`: nested geometry and the relationship between the dynamic
  cover size and the expanded track-list frame.
- `Screens/CoverFlow/CoverFlowMetrics.swift`: fixed 180-point item step, 300-point expanded size,
  and 160-point base size alongside dynamically sized covers.
- `Screens/CoverFlow/SongListView.swift`: track-list layout and selection.
- `Screens/Main/MainScreen.swift`: full-phone immersive overlay and the hardware layout.
- `Components/iPlayrScreen.swift`: embedded viewport and navigation layers, including the fixed
  300-point simulated screen height.

Paths above are relative to `iPlayr/iPlayr/`. Inspect the full parent/child size chain and safe-area
behavior. The screenshots establish the symptom; they do not establish the root cause.

### BETA-03 — Move the landscape click wheel farther right (P2)

**Observed/requested:** In [03 landscape](design/beta/2026-10-15/screenshots/03-home-landscape.jpeg),
the wheel sits too far inward for the user's preference. Move it toward the right/end of the phone.
Keep it vertically balanced and allow safe clearance for the screen, bezel and phone edge.

**Code entry point:** `iPlayr/iPlayr/Screens/Main/MainScreen.swift`, landscape `deviceLayout`.
The current centered HStack places the screen and a separately constrained wheel container side by
side. Evaluate the container placement as well as the painted wheel; validate both landscape rotations.

No exact inset or point offset has been requested. Do not derive physical points from the supplied
610 × 281 JPEG, which is a scaled image rather than an original-resolution device screenshot.

### BETA-04 — Slightly enlarge the click wheel (P2)

**User report:** The wheel feels too small. Increase it slightly. Treat this as a general sizing
request and verify portrait and landscape, including Classic and Minimal styles.

**Evidence:** [03 landscape](design/beta/2026-10-15/screenshots/03-home-landscape.jpeg),
[04 minimal portrait](design/beta/2026-10-15/screenshots/04-home-portrait-minimal.jpeg),
[05 classic portrait](design/beta/2026-10-15/screenshots/05-home-portrait-classic.jpeg).

**Code entry points:** `Components/iPodButtons.swift` computes wheel diameter as the smaller of
62%/68% of its container width and its available height minus slop. In landscape, that width is
already constrained by `Screens/Main/MainScreen.swift`. `Core/Theme/ThemeCore/WheelGeometry.swift`
provides the hit map. Size and placement should be evaluated together.

No exact percentage or diameter is approved. Preserve the circular shape, center-button proportions,
labels, ring slop and style-independent hit map. Check touch behavior after resizing; a larger paint
layer alone would not satisfy the request if its input geometry no longer matches.

## Implementation and acceptance checklist

Implementation and compilation are recorded separately from device acceptance. Checked source
changes and automated checks below do not establish that visual or playback behavior passed on a phone.

- [x] Fix Cover Flow framing/centering (`0f9312c`, 16 Oct): the backdrop's rigid 700 × 700 artwork request inflated the layout; now sized and clipped to the view. **Still to do on the Mac:** reproduce the before/after in all four combinations: Immersive On/Off × portrait/landscape.
- [ ] Verify album browsing, Tracks/Covers, playback return, exit, and orientation changes in each combination.
- [x] Change the home heading to iPod (`8af5801`, 16 Oct). **Still to do:** check it in portrait and landscape across representative themes.
- [x] Move the landscape wheel toward the right end (`e7814dd`, 16 Oct): a trailing square 20 pt from the edge. **Still to do:** confirm both rotations.
- [x] Enlarge the wheel (`e7814dd`, 16 Oct): portrait 70% / 76% compact, landscape fills the trailing square. **Still to do:** review Classic and Minimal together; confirm the hit map still matches the paint (geometry is unchanged, only the diameter grew).
- [ ] Confirm scroll, SELECT, MENU, hold MENU, transport, seek, volume, haptics and clicker remain usable.
- [x] Run native Mac ThemeCore tests: 20 tests, zero failures after declaring macOS 13 in the package.
- [x] Compile Debug for `generic/platform=iOS` with signing disabled: passed with the existing
      App Intents metadata warning only. See the saved logs linked from `BETA_TEST_LOG.md`.
- [x] Run a fresh Release Analyze action for build 3: passed, saved in the 17 October evidence folder.
- [x] Apply MAC-01 through MAC-03 locally: Mac package minimum, embedded-player shortcut guard,
      and immediate seek commit on MENU/focus handoff.
- [ ] Verify the embedded-player shortcut and immediate seek commit on MENU/hold MENU on the phone.
- [x] Build a new IPA using `bash scripts/build_ipa.sh`: version 1.3 (3), saved with a distinct
      filename. Metadata-free packaging, device platform/architecture, and archive integrity pass.
- [ ] Hand the new IPA to the user for manual SideStore installation and before/after screenshots.
- [ ] Obtain the user's review of wheel size/right alignment and Cover Flow's corrected appearance.

The user will collect screenshots manually. Do not add simulator runs or automated phone deployment
as requirements. The full 40-theme screenshot matrix from the old plan is not a gate for this focused
fix pass; prioritize the supplied failing layouts and representative theme styles.

## Logs and prior installation issue

[Evidence index](design/beta/2026-10-15/README.md) · [Observed issue log](BETA_TEST_LOG.md) ·
[Technical migration history](THEME_MIGRATION_STATUS.md).

The preserved SideStore console is an **installer log**, not an app runtime/crash log. It records
the original IPA failing at 20:28:52 and 20:29:06 with `SideStore.OperationError`, code 2, during
DownloadAppOperation. The original archive included `Payload/._iPlayr.app`, which SideStore's parser
could mistake for the app. The corrected archive removed those metadata sidecars and passed archive
checks. Subsequent screenshots show a usable installed app, but no successful installation console
or Cover Flow runtime trace has been supplied. Do not attribute Cover Flow's layout failure to the
old signing/import error.

Saved evidence includes all five original supplied JPEG files, the original SideStore console,
available Xcode Release/Analyze logs, their SHA-256 manifest, and the superseded handoff/checklist.
Original file bytes are preserved. Screenshot times visible in the status bar are around 20:37–20:40;
the exported JPEGs are 281 × 610 or 610 × 281, not native-resolution captures.

## Scope held for later

The user says the remaining tested behavior is fine. Earlier code-review concerns about bounded
song queues, album-title grouping, light-atmosphere contrast and immersive track tapping remain
separate backlog items, not newly reproduced failures from this session. Do not silently expand
this four-issue pass into those changes. Accessibility settings, full theme coverage and migration
were not individually reported as tested; retain that distinction when reporting confidence.
