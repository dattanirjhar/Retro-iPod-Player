# Release versioning

Use the user's release convention: release 1.2 is build 2, release 1.3 is build 3, and release
1.4 is build 4, and 1.5 is build 5. For each subsequent packaged update, increment the marketing minor
version and build number together (next: 1.6/build 6). Read the current Xcode values before
incrementing; source-only edits do not require a version bump.

Update the changelog, current beta notes and IPA filename to match each packaged release.
Earlier releases 1.2 and 1.3 originally embedded marketing version 1.0; preserve original logs,
checksums, artifact paths and recorded bundle metadata when using the revised release labels.
