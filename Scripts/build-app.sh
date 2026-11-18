#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != Darwin ]]; then
    printf '%s\n' 'Building the app bundle requires macOS and the Xcode command-line tools.' >&2
    exit 1
fi

cd "$(dirname "${BASH_SOURCE[0]}")/.."
root="$PWD"
dist="$root/dist"

swift build -c release --product K70Studio
bin="$(swift build -c release --show-bin-path)/K70Studio"
mkdir -p "$dist"
stage="$(mktemp -d "$dist/.build-app.XXXXXX")"
trap 'rm -rf -- "$stage"' EXIT
bundle="$stage/K70 Studio.app"
mkdir -p "$bundle/Contents/MacOS" "$bundle/Contents/Resources"

install -m 0755 "$bin" "$bundle/Contents/MacOS/K70Studio"
install -m 0644 Resources/Info.plist "$bundle/Contents/Info.plist"
install -m 0644 Resources/AppIcon.icns "$bundle/Contents/Resources/AppIcon.icns"
install -m 0644 LICENSE "$bundle/Contents/Resources/LICENSE"
plutil -lint "$bundle/Contents/Info.plist"

if [[ -n "${K70_SIGN_IDENTITY:-}" ]]; then
    codesign --force --sign "$K70_SIGN_IDENTITY" --options runtime --timestamp "$bundle"
else
    codesign --force --sign - "$bundle"
fi
codesign --verify --strict "$bundle"

app="$dist/K70 Studio.app"
if [[ -e "$app" || -L "$app" ]]; then
    mv -- "$app" "$stage/previous.app"
fi
if ! mv -- "$bundle" "$app"; then
    if [[ -e "$stage/previous.app" || -L "$stage/previous.app" ]]; then
        mv -- "$stage/previous.app" "$app"
    fi
    exit 1
fi
printf 'Built %s\n' "$app"
