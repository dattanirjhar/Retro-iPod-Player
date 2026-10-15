#!/bin/bash
# Build for physical iPhones and package an unsigned, metadata-free IPA for SideStore.
set -euo pipefail

project_dir="$(cd "$(dirname "$0")/.." && pwd)"
artifact_dir="$project_dir/DerivedData/Artifacts"
app_bundle="$project_dir/DerivedData/Build/Products/Release-iphoneos/iPlayr.app"
output_path="$artifact_dir/iPod-Playr-SideStore.ipa"
mkdir -p "$artifact_dir"

if ! xcodebuild -project "$project_dir/iPlayr/iPlayr.xcodeproj" \
    -scheme iPlayr -destination 'generic/platform=iOS' -configuration Release \
    -derivedDataPath "$project_dir/DerivedData" CODE_SIGNING_ALLOWED=NO build \
    > "$artifact_dir/build.log" 2>&1; then
    tail -n 60 "$artifact_dir/build.log"
    exit 1
fi

python3 - "$app_bundle" "$output_path" <<'PY'
import plistlib
import shutil
import subprocess
import sys
import tempfile
import zipfile
from pathlib import Path

app, output = map(Path, sys.argv[1:])
with (app / "Info.plist").open("rb") as stream:
    info = plistlib.load(stream)
assert info["CFBundleSupportedPlatforms"] == ["iPhoneOS"], "Expected a device build"
assert info.get("NSAppleMusicUsageDescription"), "Missing music privacy description"
assert "audio" in info.get("UIBackgroundModes", []), "Missing background audio mode"
assert not (app / "embedded.mobileprovision").exists(), "Expected an unsigned app"
assert not (app / "_CodeSignature").exists(), "Expected an unsigned app"

with tempfile.TemporaryDirectory(prefix="iplayr-ipa-") as staging:
    payload = Path(staging) / "Payload"
    shutil.copytree(app, payload / app.name, symlinks=True)
    # AppleDouble files such as Payload/._iPlayr.app can be mistaken for the
    # application by SideStore's first-*.app import logic. Do not archive xattrs.
    subprocess.run(["/usr/bin/ditto", "-c", "-k", "--keepParent", "--norsrc",
                    "--noextattr", "--noacl", str(payload), str(output)], check=True)

with zipfile.ZipFile(output) as archive:
    assert archive.testzip() is None, "IPA failed ZIP integrity check"
    assert f"Payload/{app.name}/{info['CFBundleExecutable']}" in archive.namelist()
    names = archive.namelist()
    assert not any(part.startswith("._") or part == "__MACOSX"
                   for name in names for part in Path(name).parts), "Unexpected macOS metadata"
    candidates = {Path(name).parts[1] for name in names
                  if len(Path(name).parts) >= 2 and Path(name).parts[0] == "Payload"
                  and Path(name).parts[1].lower().endswith(".app")}
    assert candidates == {app.name}, f"Ambiguous SideStore app candidates: {candidates}"
    assert archive.getinfo(f"Payload/{app.name}/").is_dir(), "App candidate must be a directory"
print(f"Unsigned IPA: {output}")
print(f"Version {info['CFBundleShortVersionString']} ({info['CFBundleVersion']}); SideStore must sign before installation.")
PY
