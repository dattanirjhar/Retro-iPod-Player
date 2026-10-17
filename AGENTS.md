# Release versioning

Use the user's marketing-version convention: 1.2, 1.3, 1.4, 1.5, then 1.6. Increment the marketing
minor version and build number for each new packaged release unless the user requests a specific
version. Always increment the build number for a replacement IPA, including same-version rebuilds.
The user corrected the Bold Menu release to 1.6; the replacement is 1.6/build 7. The next default
release is 1.7/build 8. Read the current Xcode values before incrementing; source-only edits do not
require a version bump.

Update the changelog, current beta notes and IPA filename to match each packaged release.
Earlier releases 1.2 and 1.3 originally embedded marketing version 1.0; preserve original logs,
checksums, artifact paths and recorded bundle metadata when using the revised release labels.
