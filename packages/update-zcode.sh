#!/usr/bin/env bash
# Refresh packages/zcode.nix to the newest ZCode desktop release.
#
# ZCode is deliberately not tracked by nvfetcher: its download URL embeds the
# version, the only thing enumerating versions is the marketing page's static
# HTML, and pulling a ~250 MB AppImage through the Nix daemon tends to stall on
# this CDN. This script scrapes the newest version, downloads with aria2c (many
# connections) or curl (resumable), verifies it against the sha512 published in
# the release's latest.yml, then rewrites version + hash in packages/zcode.nix.
# Requires: curl jq nix sed (repo devShell); aria2c is used when present.
set -euo pipefail

cd "$(dirname "$0")/.."

die() { echo "error: $*" >&2; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || die "missing dependency: $1"; }
for c in curl jq nix sed; do need "$c"; done

base=https://cdn-zcode.z.ai/zcode/electron/releases
page=https://zcode.z.ai/

current=$(sed -n 's/^  version = "\(.*\)";$/\1/p' packages/zcode.nix)
[ -n "$current" ] || die "cannot read version from packages/zcode.nix"

latest=$(
  curl -sfL --retry 3 "$page" \
    | grep -oE 'releases/[0-9]+\.[0-9]+\.[0-9]+/linux-x64/ZCode-[0-9.]+-linux-x64\.AppImage' \
    | sed -E 's|releases/([^/]+)/.*|\1|' \
    | sort -V \
    | tail -n1
)
[ -n "$latest" ] || die "cannot determine the newest zcode version from $page"

echo "zcode: $current -> $latest"
if [ "$latest" = "$current" ]; then
  echo "zcode: up to date"
  exit 0
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

appimage=ZCode-$latest-linux-x64.AppImage
url=$base/$latest/linux-x64/$appimage
yml=$tmp/latest.yml
curl -sfL --retry 3 -o "$yml" "$base/$latest/linux-x64/latest.yml"

want_sha512=$(grep -A2 -F "url: $appimage" "$yml" | sed -n 's/^ *sha512: *//p' | head -n1)
want_size=$(grep -A3 -F "url: $appimage" "$yml" | sed -n 's/^ *size: *//p' | head -n1)
{ [ -n "$want_sha512" ] && [ -n "$want_size" ]; } || die "latest.yml does not list $appimage"

img=$tmp/$appimage

fetch() {
  if command -v aria2c >/dev/null 2>&1; then
    local attempt
    for attempt in $(seq 1 10); do
      aria2c -c -x16 -s16 --file-allocation=none --no-conf --allow-overwrite=true \
        --dir "$(dirname "$img")" --out "$(basename "$img")" "$url" >/dev/null && return 0
      echo "zcode: download interrupted, resuming ($attempt/10)" >&2
    done
    return 1
  fi
  local attempt size
  for attempt in $(seq 1 30); do
    size=$(stat -c %s "$img" 2>/dev/null || echo 0)
    [ "$size" -ge "$want_size" ] && return 0
    curl --http1.1 -L -C - --max-time 300 --retry 2 -o "$img" "$url" || true
    echo "zcode: download interrupted, resuming ($attempt/30)" >&2
  done
  return 1
}

echo "zcode: downloading $appimage ($((want_size / 1024 / 1024)) MiB)"
fetch || die "download failed"

size=$(stat -c %s "$img")
[ "$size" = "$want_size" ] || die "size mismatch: got $size, want $want_size"

got_sha512=$(nix hash file --type sha512 --base64 "$img")
[ "$got_sha512" = "$want_sha512" ] || die "sha512 mismatch: got $got_sha512, want $want_sha512"

hash=$(nix hash file --type sha256 --sri "$img")

# Put the verified AppImage in the store now: fetchurl's output path is the
# same flat file, so `nix build .#zcode` reuses it instead of pulling another
# 250 MB through the Nix daemon.
nix store add-file --name "$appimage" "$img" >/dev/null

sed -i "s|^  version = \".*\";|  version = \"$latest\";|" packages/zcode.nix
sed -i "s|^    hash = \"sha256-[^\"]*\";|    hash = \"$hash\";|" packages/zcode.nix

echo "zcode: wrote $latest ($hash)"
echo "zcode: verify with \`nix build .#zcode\`"
