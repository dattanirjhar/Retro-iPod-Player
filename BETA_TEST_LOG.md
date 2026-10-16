# Beta observations — 15 October 2026

**Latest update:** the 16 October Mac review and three follow-up fixes are recorded below.
The updated source passes 20 ThemeCore tests and an unsigned Debug iOS build; device acceptance
is still pending. The following device/build details describe the original 15 October candidate.

Device: iPhone 17 · iOS 27.0.1 · app 1.0 (1) · manually installed using SideStore.
Build tools: Xcode 27.0 (27A266a), iOS 27.0 SDK. Source: baseline `679be9b` plus uncommitted Phase 2
build/configuration and packaging fixes. Candidate: `DerivedData/Artifacts/iPod-Playr-SideStore.ipa`.

**Current plan and pending acceptance checks:** [prod-dev-team handoff for 16 October](PHASE2_MAC_HANDOFF.md).
This observed-results log replaces the earlier blank checklist. Its previous version is in the
[evidence archive](design/beta/2026-10-15/archive/BETA_TEST_LOG.md).

## Reported result

The app launched and was used on the phone. The user reports that the rest of their tested use is
working fine, except for the issues below. No individual pass is inferred for unreported background
playback, migration, relaunch or accessibility scenarios. The user intends to avoid/deactivate Cover
Flow for now. No app preference, feature flag or implementation was changed in this documentation pass.

| ID | Priority | Observation / requested outcome | Evidence | Status |
| --- | --- | --- | --- | --- |
| BETA-01 | P2 | Home heading says iPlayr; it must say iPod. | Screenshots 03, 04, 05 | Fixed 2026-10-16 in `8af5801` (`HomeListView` title). Awaiting device check |
| BETA-02 | P1 | Cover Flow is misaligned and clipped; user reports failure with Immersive Mode On and Off. Selected cover/text/controls clip in portrait; landscape covers run below the visible area. | Screenshots 01, 02; user's explicit report for both modes | Fixed 2026-10-16 in `0f9312c`. Cause: the backdrop requested a rigid 700 × 700 `ArtworkImage`, inflating the layout by (700 − width)/2 ≈ 155 pt right in portrait and (700 − height)/2 down in landscape, in both Immersive settings. Backdrop now sized and clipped to the view; whole screen pinned to its measured size. Awaiting device check in all four combinations |
| BETA-03 | P2 | Landscape wheel sits too far inward; move it toward the right/end of the phone. | Screenshot 03 | Fixed 2026-10-16 in `e7814dd`: landscape reserves a square at the trailing edge (20 pt from the edge) and the wheel fills it. Awaiting user review in both landscape rotations |
| BETA-04 | P2 | Wheel feels too small; enlarge it slightly and check both orientations/styles. | Screenshots 03, 04, 05; user's tactile feedback | Fixed 2026-10-16 in `e7814dd`: portrait 70% of body width (76% compact), was 62% / 68%; landscape sized from the height (about 300 pt on a 390 pt-tall phone, was about 178 pt). Hit map unchanged. Awaiting user review |
| INSTALL-01 | Historical blocker | Original IPA rejected twice as invalid format before signing. Removed ambiguous macOS metadata sidecars in the replacement package. | Preserved SideStore console at 20:28:52 and 20:29:06 | Packaging corrected earlier; later screenshots establish app launch, without a success-install log |

See the [evidence index](design/beta/2026-10-15/README.md) for image links and saved logs. Exact
Immersive Mode state is not labeled per screenshot; use the user report to cover both states.

## Verification already recorded on the Mac

- 13 ThemeCore XCTest tests passed, including 540 contrast checks.
- Release iPhone build and Debug Analyze passed.
- Corrected IPA passed ZIP, arm64/iPhoneOS metadata, executable permissions, one-app-candidate and
  no-AppleDouble checks. It remains unsigned until SideStore signs it.
- App-module iOS tests were not run; no Xcode test target is configured.
- No tests, builds or app-code changes were performed in the documentation-only beta handoff pass.

## Fix pass, 16 October 2026 (Linux, not yet rebuilt)

All four items are implemented and committed (`8af5801`, `0f9312c`, `e7814dd`); ten orphaned app-icon PNGs were also removed (`b36cce4`) to clear the unassigned-children build warning. At this Linux handoff, the changes had not been compiled or installed. The later Mac compilation is recorded below; a new IPA and device checks remain pending for every item above.

## Mac review and follow-up fixes — 16 October 2026

Reviewed the eight commits pulled onto `main`, `58ae10f..1c58974`, authored by `tattva`.
They include BETA-01 through BETA-04, removal of ten unused icons, queue browsing and jumping,
song actions (Play Now / Play Next / Add to End of Queue), settled wheel seeking, the hold
Play/Pause shortcut, and updated documentation. Search is an ideation memo only; no search
implementation was added. The full commit list is in [the handoff](HANDOFF_2026-10-16.md).

The review found three issues. The user authorized fixing all three; these changes are local
and uncommitted on top of `1c58974` at the time of this entry.

| ID | Finding and fix | Files | Verification |
| --- | --- | --- | --- |
| MAC-01 | Native Mac tests failed because the new scrubber uses `Duration`, available from macOS 13, while the package had no matching deployment minimum. Declared `.macOS(.v13)`. | `ThemeCore/Package.swift` | Reproduced the compiler error; all 20 tests pass after the fix. |
| MAC-02 | The Now Playing shortcut checked only the outer route, so it missed Cover Flow's embedded player. Added `FocusScope.isPlayerScreen`, marked player scopes, and checked the active scope before pushing another player. | `iPlayr/iPlayr/Core/Managers/UI/FocusScope.swift`, `iPlayr/iPlayr/Screens/Player/PlayerView.swift`, `iPlayr/iPlayr/Components/iPlayrScreen.swift` | Compiles successfully. Device check of embedded Cover Flow remains pending. |
| MAC-03 | MENU navigation left pending seeking to the disappearance callback or the 400 ms timer. MENU now flushes before navigating. `FocusScope.onDeactivate` also flushes when another scope takes the wheel, covering hold MENU and other focus changes while views remain mounted. Reactivating the same scope does not deactivate it. | `iPlayr/iPlayr/Core/Managers/UI/FocusScope.swift`, `iPlayr/iPlayr/Core/Managers/UI/iPlayrButtonController.swift`, `iPlayr/iPlayr/Screens/Player/PlayerView.swift` | Compiles successfully; existing seek model tests pass. Immediate commit behavior still needs device verification. |

### Executed verification

Xcode 27.0 (27A266a), iOS 27.0 SDK. Final test and build results were recorded at approximately
23:32 IST on 16 October. Commands were run from the repository root:

```bash
CLANG_MODULE_CACHE_PATH=/private/tmp/ipod-review-clang-cache \
SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/ipod-review-swift-cache \
swift test --disable-sandbox --package-path ThemeCore --scratch-path /private/tmp/ipod-review-tests

xcodebuild -project iPlayr/iPlayr.xcodeproj -scheme iPlayr \
  -configuration Debug -destination 'generic/platform=iOS' \
  -derivedDataPath /private/tmp/ipod-review-derived CODE_SIGNING_ALLOWED=NO build

git diff --check
```

- **Passed:** 20 XCTest tests, zero failures: 7 seek tests, 2 color tests, 1 contrast test
  (540 checks), 5 selection/migration tests, 3 theme-table tests, and 2 wheel-geometry tests.
  The trailing Swift Testing runner reports zero tests because this suite uses XCTest.
- **Passed:** unsigned Debug build for a generic physical iOS device. The new MusicKit queue
  APIs compile with this SDK. No unused app-icon warning was emitted.
- **Build warning, verbatim:** `warning: Metadata extraction skipped, no AppIntents.framework dependency found`.
- **Test environment warnings:** SwiftPM user caches were inaccessible/read-only under the
  execution sandbox; the warnings did not prevent the successful test run. Xcode compilation
  required running outside that sandbox so Swift macro plugins and Xcode services could work.
- **Passed:** `git diff --check` after the source fixes.
- **Not executed:** app-module iOS tests, a new Analyze action, Release packaging, simulator
  interaction tests, phone installation, or device acceptance checks. No new IPA was generated
  and the build number was not changed. The existing 15 October IPA is still the previous candidate.

Saved evidence: [original Mac test failure](design/beta/2026-10-16/logs/theme-core-before-fix.log),
[20-test pass](design/beta/2026-10-16/logs/theme-core-after-fix.log), and
[successful Debug iOS build](design/beta/2026-10-16/logs/xcode-debug-device-build.log).

### Remaining acceptance checks

- [ ] With Immersive Mode off, open Cover Flow's player and hold Play/Pause: no second player
      opens. From Cover Flow's browsing or track list, the shortcut still opens Now Playing;
      MENU returns to the previous screen and selection.
- [ ] In Seek mode, turn the wheel and immediately press MENU: the target commits on exit.
      Repeat with hold MENU, opening Queue, and returning from the embedded Cover Flow player.
- [ ] Confirm ordinary seeking still settles once after 400 ms, switching modes commits,
      and changing tracks discards the pending seek.
- [ ] Verify queue jumps, Play Next, Add to End of Queue, empty-queue behavior, song actions,
      shortcut return paths, and VoiceOver actions on the phone.
- [ ] Complete BETA-01 through BETA-04 visual/touch checks with the next installed candidate.

## Next result to record

For the next IPA, record its version/build, installation outcome, BETA-01 through BETA-04 results,
Immersive On/Off plus orientation for each Cover Flow screenshot, and the user's review of wheel
placement/size. Keep the current screenshots as the before set; do not overwrite them.
