#!/usr/bin/env bash
# Update the hand-maintained packages in packages/.
#
#   packages/update.sh <pkg> [version]
#
# <pkg> is one of: dsh cc-switch clipvault splitrail revelo (or "all").
# Requires: curl jq nix sed. dsh additionally needs npm and
# prefetch-npm-deps (both are in the repo devShell, see flake.nix).
# After updating, verify with: nix build .#<pkg>
set -euo pipefail

cd "$(dirname "$0")/.."

die() { echo "error: $*" >&2; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || die "missing dependency: $1"; }

for c in curl jq nix sed; do need "$c"; done

# url -> SRI hash of the file
sri() { nix store prefetch-file --json "$1" | jq -r -e .hash; }
# url -> SRI hash of the *unpacked* archive (for fetchzip)
sri_unpack() { nix store prefetch-file --unpack --json "$1" | jq -r -e .hash; }

gh_latest() { # owner/repo -> latest release version (no leading v)
  curl -sf "https://api.github.com/repos/$1/releases/latest" | jq -r -e .tag_name | sed 's/^v//'
}

set_version() { # file version — first `version = "..."` line
  sed -i "0,/^  version = \".*\";/s//  version = \"$2\";/" "$1"
}

set_hash() { # file field hash — first `field = "..."` line
  # use "|" delimiter: SRI hashes contain "/" and "+"
  sed -i "0,/  $2 = \".*\";/s||  $2 = \"$3\";|" "$1"
}

set_platform_hash() { # file block-pattern field hash — `field` inside the `<pattern> = { ... };` block
  sed -i "/$2 = {/,/};/ s|$3 = \".*\";|$3 = \"$4\";|" "$1"
}

update_dsh() {
  need npm; need prefetch-npm-deps
  local ver="${1:-}"
  if [ -z "$ver" ]; then
    # Newest dsh release on GitHub, prereleases included (the alpha line only
    # ever appears there / under npm's `alpha` dist-tag, never `latest`).
    ver=$(curl -sf "https://api.github.com/repos/deepseek-ai/deepseek-harness/releases?per_page=100" |
      jq -r -e '.[].tag_name | select(startswith("dsh-v")) | sub("^dsh-v"; "")' |
      sort -V | tail -n1)
  fi
  echo "dsh: $ver"
  local url="https://registry.npmjs.org/@deepseek-ai/dsh/-/dsh-${ver}.tgz"
  # GitHub releases ship no assets and don't always get an npm publish
  # (e.g. 0.1.3-alpha.1), so check the tarball exists before depending on it.
  curl -sfI "$url" >/dev/null 2>&1 ||
    die "no npm tarball for @deepseek-ai/dsh@${ver} (GitHub release without npm publish)"

  local src_hash deps_hash
  src_hash=$(sri_unpack "$url")

  # Regenerate the vendored package-lock.json from the npm tarball with
  # devDependencies dropped, mirroring dsh.nix's postPatch.
  local tmp; tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' RETURN
  curl -sfL "$url" | tar -xz -C "$tmp"
  jq 'del(.devDependencies)' "$tmp/package/package.json" > "$tmp/package.json.new"
  mv "$tmp/package.json.new" "$tmp/package/package.json"
  (cd "$tmp/package" && npm install --package-lock-only --ignore-scripts --no-audit --no-fund >/dev/null)
  cp "$tmp/package/package-lock.json" packages/dsh-package-lock.json
  deps_hash=$(prefetch-npm-deps packages/dsh-package-lock.json | tail -n1)

  sed -i \
    -e "s|^  version = \".*\";|  version = \"$ver\";|" \
    -e "s|^  srcHash = \".*\";|  srcHash = \"$src_hash\";|" \
    -e "s|^  npmDepsHash = \".*\";|  npmDepsHash = \"$deps_hash\";|" \
    packages/dsh.nix
}

update_cc_switch() {
  local ver; ver=$(gh_latest farion1231/cc-switch)
  echo "cc-switch: $ver"
  local url="https://github.com/farion1231/cc-switch/releases/download/v${ver}/CC-Switch-v${ver}-macOS.zip"
  set_version packages/cc-switch.nix "$ver"
  set_hash packages/cc-switch.nix hash "$(sri "$url")"
}

update_clipvault() {
  local ver; ver=$(gh_latest rolv-apneseth/clipvault)
  echo "clipvault: $ver"
  set_version packages/clipvault.nix "$ver"
  local target hash
  for target in x86_64-unknown-linux-gnu aarch64-unknown-linux-gnu; do
    hash=$(sri "https://github.com/rolv-apneseth/clipvault/releases/download/v${ver}/clipvault-${target}.tar.gz")
    set_platform_hash packages/clipvault.nix "${target%%-*}-linux" sha256 "$hash"
  done
}

update_splitrail() {
  local ver; ver=$(gh_latest Piebald-AI/splitrail)
  echo "splitrail: $ver"
  set_version packages/splitrail.nix "$ver"
  local pair sys platform hash
  for pair in \
    "x86_64-linux:x86_64-unknown-linux-musl" \
    "aarch64-linux:aarch64-unknown-linux-musl" \
    "x86_64-darwin:x86_64-apple-darwin" \
    "aarch64-darwin:aarch64-apple-darwin"; do
    sys="${pair%%:*}"; platform="${pair#*:}"
    hash=$(sri "https://github.com/Piebald-AI/splitrail/releases/download/v${ver}/splitrail-v${ver}-${platform}.tar.gz")
    set_platform_hash packages/splitrail.nix "\"${sys}\"" hash "$hash"
  done
}

update_revelo() {
  local ver; ver=$(gh_latest vbasky/revelo)
  echo "revelo: $ver"
  set_version packages/revelo.nix "$ver"
  set_hash packages/revelo.nix hash "$(sri "https://github.com/vbasky/revelo/releases/download/v${ver}/revelo-v${ver}-aarch64-apple-darwin.tar.gz")"
}

pkg="${1:-}"; shift || true
case "$pkg" in
  dsh) update_dsh "$@" ;;
  cc-switch) update_cc_switch ;;
  clipvault) update_clipvault ;;
  splitrail) update_splitrail ;;
  revelo) update_revelo ;;
  all) update_dsh "$@"; update_cc_switch; update_clipvault; update_splitrail; update_revelo ;;
  *) die "usage: $0 {dsh|cc-switch|clipvault|splitrail|revelo|all} [version]" ;;
esac
