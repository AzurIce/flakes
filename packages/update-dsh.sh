#!/usr/bin/env bash
# Regenerate the npm side of packages/dsh.nix after nvfetcher bumps its
# version (`just update`). nvfetcher (packages/nvfetcher.toml) already tracks
# the dsh version and src hash; this only rebuilds the vendored
# packages/dsh-package-lock.json (devDependencies dropped, mirroring dsh.nix's
# postPatch) and refreshes npmDepsHash in packages/dsh.nix.
# Requires: curl jq npm prefetch-npm-deps sed (all in the repo devShell).
set -euo pipefail

cd "$(dirname "$0")/.."

die() { echo "error: $*" >&2; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || die "missing dependency: $1"; }
for c in curl jq npm prefetch-npm-deps sed; do need "$c"; done

ver=$(jq -r -e '.dsh.version' packages/_sources/generated.json)
echo "dsh: $ver"

# `just update` runs this on every bump of any package; skip the expensive lock
# regeneration when the vendored lock already matches the pinned version.
locked=$(jq -r '.packages[""].version // ""' packages/dsh-package-lock.json 2>/dev/null || true)
if [ "$locked" = "$ver" ]; then
  echo "dsh: lock up to date, skipping"
  exit 0
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
url="https://registry.npmjs.org/@deepseek-ai/dsh/-/dsh-${ver}.tgz"
curl -sfL "$url" | tar -xz -C "$tmp"
jq 'del(.devDependencies)' "$tmp/package/package.json" > "$tmp/package.json.new"
mv "$tmp/package.json.new" "$tmp/package/package.json"
(cd "$tmp/package" && npm install --package-lock-only --ignore-scripts --no-audit --no-fund >/dev/null)
cp "$tmp/package/package-lock.json" packages/dsh-package-lock.json

deps_hash=$(prefetch-npm-deps packages/dsh-package-lock.json | tail -n1)
sed -i "s|^  npmDepsHash = \".*\";|  npmDepsHash = \"$deps_hash\";|" packages/dsh.nix
echo "dsh: npmDepsHash = $deps_hash"
