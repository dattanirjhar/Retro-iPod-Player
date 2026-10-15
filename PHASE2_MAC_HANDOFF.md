# Beta handoff for prod-dev-team — 16 October 2026

Prepared from the user's 15 October 2026 beta session on an iPhone 17 running iOS 27.0.1.
This is the current plan and acceptance checklist. It replaces the earlier Mac setup/simulator
plan and the empty device checklist. Their previous versions are preserved in the
[evidence archive](design/beta/2026-10-15/archive/).

## Direction from the user

**Document the findings now. Apply the fixes tomorrow.** No app code, layout, preferences, theme
constants or IPA was changed or rebuilt while preparing this handoff.

The user reports that the rest of their tested use is working fine. Keep the next pass focused on
these four issues. Cover Flow is unusable enough that the user intends to deactivate or avoid it
while using the app. That is the user's temporary workaround; no feature flag or removal has been
implemented. The Immersive Mode setting changes presentation and does not disable Cover Flow itself.

## Current build and verification

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

## Tomorrow's implementation and acceptance checklist

All items below are **pending**. The team should implement during the next development session;
this document is not evidence that the changes have been made.

- [ ] Reproduce BETA-02 in all four combinations: Immersive On/Off × portrait/landscape.
- [ ] Fix Cover Flow framing/centering, including safe areas, titles, controls and expanded tracks.
- [ ] Verify album browsing, Tracks/Covers, playback return, exit, and orientation changes in each combination.
- [ ] Change the home heading to iPod; check it in portrait and landscape across representative themes.
- [ ] Move the landscape wheel toward the right end, keeping safe margins in both rotations.
- [ ] Slightly enlarge the wheel in both orientations; review Classic and Minimal styles together.
- [ ] Confirm scroll, SELECT, MENU, hold MENU, transport, seek, volume, haptics and clicker remain usable.
- [ ] Run `swift test --package-path ThemeCore` and physical-device compilation/analysis; record exact results.
- [ ] Build a new IPA using `bash scripts/build_ipa.sh`; give it a distinct build number or filename so
      the user can identify the next candidate. Preserve the metadata-free SideStore packaging check.
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
