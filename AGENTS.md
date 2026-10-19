# Start here

Read [HANDOFF.md](HANDOFF.md) before changing code. It is the current handoff for agents and
prod-dev-team, with accepted settings, source entry points, verification, open issues and next steps.
Then read the linked current beta record and version policy. Dated handoff files and older beta-log
entries are historical snapshots; their local/uncommitted, version and retained-artifact statements
apply at their original dates. Do not treat old designs or plans as current requirements.

Keep source completion, automated verification and manual device acceptance distinct. Record new
work and its actual checks in CHANGELOG.md / BETA_TEST_LOG.md; save durable evidence under a dated
design/beta folder. Keep HANDOFF.md and current pointers accurate when handing off. Do not require
access to prior chat, local visualization paths or temporary scripts to understand shipped behavior.

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
Use `iPod-<version>.ipa` names, e.g. `iPod-2.7.4.ipa`, and retain only the latest verified IPA.
The user approved regrouping old release labels; the mapping is in RELEASE_VERSIONING.md.
Preserve original embedded metadata, raw logs, artifact paths, checksums and Git history. Add
canonical labels separately; never present relabeling as a change to a historical binary.
