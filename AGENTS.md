# Release versioning

Follow [RELEASE_VERSIONING.md](RELEASE_VERSIONING.md). The user finalized **2.milestone.build**:
iPodPlayer is the 1.x predecessor; our 20-theme redesign begins 2.1. Advance the middle component
for major design changes OR major feature additions, including Search. Start the last component
at 1 for each new milestone; increase it for packaged fixes/refinements/rebuilds within that milestone.
Source-only edits, commits and local Debug/test builds do not consume release numbers.

Set MARKETING_VERSION to the full dotted version. About displays only that string, with no brackets.
CURRENT_PROJECT_VERSION is a separate globally increasing internal installation counter; do not
reset it with a milestone or require it to equal the last visible component. Keep Debug/Release equal.
Read current project metadata and packaging records before assigning the next unused numbers.
Current release: 2.7.4, internal counter 9. Next fix: 2.7.5; next major feature/design milestone: 2.8.1.
Honor explicitly requested versions without reusing a previously packaged internal counter.

Update the changelog, current beta notes, captured settings, handoff pointers and IPA filename.
Use `iPod-Playr-SideStore-2.7.4.ipa` style names and retain only the latest verified IPA.
The user approved regrouping old release labels; the mapping is in RELEASE_VERSIONING.md.
Preserve original embedded metadata, raw logs, artifact paths, checksums and Git history. Add
canonical labels separately; never present relabeling as a change to a historical binary.
