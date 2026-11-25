#!/usr/bin/env bash
# Builds this checkout and installs it as `axe`. The fork has no Homebrew package,
# so this replaces `brew install`. Run it from anywhere inside the checkout.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
dest="${AXE_INSTALL_DIR:-$HOME/.local/opt/axe}"
bin_dir="${AXE_BIN_DIR:-$HOME/.local/bin}"

cd "$root"
# build.sh deletes build_products/ when it rebuilds stale frameworks, so nothing else may live there.
scripts/build.sh frameworks-if-needed
# VersionPlugin declares no inputs, so SwiftPM keeps a stale Version.swift and `axe --version` would name an old commit.
find .build/plugins/outputs -path '*VersionPlugin/Version.swift' -delete 2>/dev/null || true
swift build -c release

# axe finds its frameworks and resource bundle through @executable_path, so the four items stay together.
stage="$dest.new"
rm -rf "$stage"
mkdir -p "$stage" "$bin_dir"
release=.build/release
cp -R "$release/axe" "$release/AXe_AXe.bundle" "$release/FBControlCore.framework" "$release/FBSimulatorControl.framework" "$stage"
xattr -crs "$stage"
# Frameworks first: signing axe seals the frameworks it embeds.
codesign --force --sign - "$stage/FBControlCore.framework" "$stage/FBSimulatorControl.framework"
codesign --force --sign - "$stage/axe"

# Keep the previous install so a bad build can be rolled back.
rm -rf "$dest.old"
[[ -e "$dest" ]] && mv "$dest" "$dest.old"
mv "$stage" "$dest"
ln -sfn "$dest/axe" "$bin_dir/axe"

"$bin_dir/axe" --version
case ":$PATH:" in
  *":$bin_dir:"*) ;;
  *) echo "Add $bin_dir to PATH to run axe." >&2 ;;
esac
