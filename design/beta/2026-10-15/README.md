# Evidence from the 15 October 2026 beta session

Current instructions: [prod-dev-team handoff](../../../PHASE2_MAC_HANDOFF.md).
Device: iPhone 17, iOS 27.0.1. The images and console were supplied by the user. Images are saved
byte-for-byte from the supplied JPEG exports; no crop, annotation, regeneration or rescaling was applied.
Original names, sizes, dimensions and SHA-256 checksums are recorded in [manifest.json](manifest.json).

## Screenshots

| # | Saved file | What it shows | Related issues |
| --- | --- | --- | --- |
| 01 | [Cover Flow portrait](screenshots/01-coverflow-portrait.jpeg) | Selected cover, title and controls cut off at right | BETA-02 |
| 02 | [Cover Flow landscape](screenshots/02-coverflow-landscape.jpeg) | Covers low/clipped vertically; exit button visible | BETA-02 |
| 03 | [Home landscape](screenshots/03-home-landscape.jpeg) | iPlayr heading; current inward/small wheel placement | BETA-01, BETA-03, BETA-04 |
| 04 | [Home portrait, Minimal wheel](screenshots/04-home-portrait-minimal.jpeg) | iPlayr heading; outline wheel | BETA-01, BETA-04 |
| 05 | [Home portrait, Classic wheel](screenshots/05-home-portrait-classic.jpeg) | iPlayr heading; filled wheel | BETA-01, BETA-04 |

Images are 281 × 610 or 610 × 281. Exact Immersive Mode states and theme IDs were not recorded per
image. Both mode settings failing is the user's explicit report; do not claim all four mode/orientation
combinations have a distinct screenshot here.

## Logs

- [Original SideStore console](logs/console_20261015_202822_592.log): installer session from
  20:28:22 to 20:29:40. Includes the two invalid-format failures for the original IPA. It does
  not capture the app's runtime or a Cover Flow crash.
- [Xcode Release build output](logs/xcode-release-build.log): successful build of the delivered candidate.
- [Xcode Debug Analyze output](logs/xcode-debug-analyze.log): successful analysis; includes known
  unassigned-icon and skipped App Intents metadata warnings.

No raw ThemeCore test-output file was retained in the earlier run. The 13-test pass and 540-assertion
contrast sweep are recorded in the chat and technical status document; do not describe a summary as a
saved raw test log. No app runtime/crash log has been supplied.

## Superseded documents

- [Previous Mac plan](archive/PHASE2_MAC_HANDOFF.md)
- [Previous beta checklist](archive/BETA_TEST_LOG.md)

These are historical snapshots. Their simulator instructions and pending-first-launch status are
superseded by the current handoff and user-reported beta results.
