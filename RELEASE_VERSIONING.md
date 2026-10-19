# Release numbering

Finalized on 19 October 2026: **2.milestone.build**, with no brackets or additional build suffix
in the app. iPodPlayer is the 1.x predecessor; iPod-Playr's 20-theme redesign begins series 2 at
milestone 1. Major feature additions count alongside major design changes.

## Rules

| Component | Meaning | Rule |
| --- | --- | --- |
| `2` | Reworked project series | Keep at 2. The predecessor belongs to series 1. |
| `7` | Feature or design milestone | Advance for a substantial feature or design addition. Search qualifies; routine fixes, small visual refinements and packaging changes do not. |
| `4` | Packaged build within the milestone | Start at 1 for each new milestone, then increase for its fixes and replacement packages. |

Current release: **2.7.4**. Next ordinary packaged fix: **2.7.5**. A new milestone next, such as
Search, would be **2.8.1**. Treat components as integers: 2.7.10 follows 2.7.9.
Source commits, documentation edits and local Debug/test builds do not consume release numbers.
One release can include several milestones that landed together; name the package after the
highest included milestone and record all included milestones. Do not invent separate IPAs for them.

## Milestone history

| Milestone | Scope | Source evidence |
| --- | --- | --- |
| 2.1 | Initial 20-theme system, independent screen modes and wheel styling | `08eedd0`, recovered baseline; initial beta through `58ae10f` |
| 2.2 | Queue, song actions, settled seeking and Now Playing shortcut | `b202915`, follow-up fixes `4b188ef` |
| 2.3 | Cover Flow layout/spacing, individual immersive track selection, normal Now Playing and preserved return navigation | `ede1582`, following the initial layout fixes |
| 2.4 | Album Glow Ambient Screen and distinct artwork-driven glass treatments | `ede1582` |
| 2.5 | Frosted, Ceramic and engraved/inlaid Porcelain redesign; Clear retired | `93eaad6` |
| 2.6 | Simplified Settings, expanded About and development changelog | `93eaad6` |
| 2.7 | Wide double Menu symbol, bare Frosted wheel symbols and soft shadows | `86cf1e1`; Bold refinement `33891e9` |

## Packaged-release labels

The user approved regrouping the historical labels. Original binary metadata remains unchanged.

| Canonical label | Original marketing version | Internal build | Source or evidence |
| --- | --- | --- | --- |
| 2.1.1 | 1.0 | 1 | `58ae10f`; [initial beta](design/beta/2026-10-15/README.md) |
| 2.2.1 | 1.0 | 2 | Source through `4b188ef`; [report](design/beta/2026-10-16/logs/ipa-build-2-verification.json) |
| 2.4.1 | 1.0 | 3 | `ede1582`; includes milestones 2.3 and 2.4 |
| 2.6.1 | 1.4 | 4 | `93eaad6`; includes milestones 2.5 and 2.6 |
| 2.7.1 | 1.5 | 5 | `86cf1e1`; wide double controls |
| 2.7.2 | 1.5 | 6 | `33891e9`; Bold Menu refinement |
| 2.7.3 | 1.6 | 7 | `c1aedb3`; version-correction package |
| 2.7.4 | 2.7.4 | 9 | [Current beta](design/beta/2026-10-19/README.md); artwork shuffle and dotted version display |

Internal build 8 was an undelivered intermediate candidate produced before the numbering discussion
finished. Its [metadata and hash](design/beta/2026-10-19/logs/superseded-numbering-candidate.json)
are preserved; it is not an additional milestone or delivered release.

Earlier human labels 1.2 and 1.3 described original internal builds 2 and 3; preserve them as legacy
aliases. Internal build 2 used a local Xcode version change that was not committed separately.
Do not rewrite Git history, raw logs, embedded-version fields, checksums or original artifact paths.
Canonical labels describe today's release history; the original fields record what the old IPA contained.
Earlier dated next-release and retention statements apply at their original dates.

## Xcode and packaging

- `MARKETING_VERSION` / `CFBundleShortVersionString` contains the complete visible version: `2.7.4`.
  About displays only that string. The IPA filename is `iPod-Playr-SideStore-2.7.4.ipa`.
- `CURRENT_PROJECT_VERSION` / `CFBundleVersion` is a separate internal installation counter. Always
  increase it globally for a new or replacement IPA; do not reset it at milestone boundaries or
  require it to match the final visible version component. Both Xcode configurations must agree.
- Read the current project values and packaging records before choosing the next unused numbers.
  Once a candidate IPA is produced, its internal counter is consumed even if rejected. A failed
  compile with no IPA does not consume one. SideStore re-signing is installation, not a new release.
- Move included Unreleased changes into a dated dotted-version changelog entry. Update the current
  README, beta notes, settings capture and handoff pointers. The script's unversioned IPA is staging;
  verify it, then promote it under the dotted version filename and retain only the latest IPA.
- Record embedded version, internal counter, size, SHA-256, platform and source identity. If packaging
  precedes the release commit, record the base commit and changes, identify the final commit when reporting
  the completed release. Preserve original evidence before removing a superseded IPA.
