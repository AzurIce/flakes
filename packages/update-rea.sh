#!/usr/bin/env bash
# Regenerate REA's vendored runtime lockfile and npmDepsHash after
# `just update` refreshes its version and tarball through nvfetcher.
# Requires: curl jq npm prefetch-npm-deps sed (available in the repo devShell).
set -euo pipefail

cd "$(dirname "$0")/.."

die() { echo "error: $*" >&2; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || die "missing dependency: $1"; }
for c in curl jq npm prefetch-npm-deps sed tar; do need "$c"; done

ver=$(jq -r -e '.rea.version' packages/_sources/generated.json)
url=$(jq -r -e '.rea.src.url' packages/_sources/generated.json)
echo "rea: $ver"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
curl --fail --silent --show-error --location --retry 3 "$url" | tar -xz -C "$tmp"
jq -e --arg version "$ver" '.name == "rea-agents" and .version == $version' \
  "$tmp/package/package.json" >/dev/null || die "tarball manifest does not match nvfetcher"
jq 'del(.devDependencies)' "$tmp/package/package.json" > "$tmp/package.json.new"
mv "$tmp/package.json.new" "$tmp/package/package.json"
(cd "$tmp/package" && npm install --package-lock-only --ignore-scripts --no-audit --no-fund >/dev/null)

deps_hash=$(prefetch-npm-deps "$tmp/package/package-lock.json" | tail -n1)
[[ "$deps_hash" == sha256-* ]] || die "prefetch-npm-deps did not return a SHA-256 hash"
cp "$tmp/package/package-lock.json" packages/rea-package-lock.json
# Use an explicit backup suffix for both BSD and GNU sed.
sed -i.bak "s|^  npmDepsHash = .*;|  npmDepsHash = \"$deps_hash\";|" packages/rea.nix
rm packages/rea.nix.bak
echo "rea: npmDepsHash = $deps_hash"
