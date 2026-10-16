# Beta observations — 15 October 2026

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

All four items are implemented and committed (`8af5801`, `0f9312c`, `e7814dd`); ten orphaned app-icon PNGs were also removed (`b36cce4`) to clear the unassigned-children build warning. Nothing has been compiled or installed since: the Mac team must rebuild with `bash scripts/build_ipa.sh`, bump the build number, and hand over a new IPA. Verification status for every item above is therefore *awaiting device check*.

## Next result to record

For the next IPA, record its version/build, installation outcome, BETA-01 through BETA-04 results,
Immersive On/Off plus orientation for each Cover Flow screenshot, and the user's review of wheel
placement/size. Keep the current screenshots as the before set; do not overwrite them.
