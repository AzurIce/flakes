# DeepSeek Harness (dsh) — open-source agent harness by DeepSeek AI
# https://github.com/deepseek-ai/deepseek-harness
#
# Adapted from https://github.com/chinrw/deepseek-harness-nix (MIT), which
# tracks the nixpkgs PR NixOS/nixpkgs#552467. Tracks the newest GitHub
# release (prereleases included) of deepseek-ai/deepseek-harness; the source
# is still the matching npm tarball since GitHub releases ship no assets.
# Update with `packages/update.sh dsh`.

{ lib
, stdenv
, buildNpmPackage
, fetchzip
, nodejs_24
, python3
, jq
}:

let
  version = "0.1.3-alpha.2";
  srcHash = "sha256-4OY3mRySTrTaFTJ274vYAzsAkNNMP4RHcukX13UHHnc=";
  npmDepsHash = "sha256-7Tkhn7bSfArwcAdIQ2pN+Yww/ze3cj7kA+Oj2AQ2yA8=";
in
(buildNpmPackage.override { nodejs = nodejs_24; }) {
  pname = "deepseek-harness";
  inherit version npmDepsHash;

  src = fetchzip {
    url = "https://registry.npmjs.org/@deepseek-ai/dsh/-/dsh-${version}.tgz";
    hash = srcHash;
  };

  # python3 is required for the node-gyp fallback when node-pty has no
  # usable prebuild for the current platform.
  nativeBuildInputs = [ python3 ];

  # The npm tarball ships prebuilt JS; devDependencies only exist for the
  # monorepo build. Drop them so the vendored lockfile (generated without
  # them) stays in sync with package.json for `npm ci`. jq is referenced by
  # absolute path because this hook also runs inside the fetchNpmDeps
  # derivation, which does not get our nativeBuildInputs.
  postPatch = ''
    ${jq}/bin/jq 'del(.devDependencies)' package.json > package.json.new
    mv package.json.new package.json
    cp ${./dsh-package-lock.json} package-lock.json
  '';

  dontNpmBuild = true;

  # dsh re-creates the cordis HMR service after the web bundle disables its
  # row (it watches the user's patch files), and that service requires Node
  # internal-module access. The shipped `node-addon-require-builtin` prebuild
  # is broken on this Node/V8 ("x64 sysv getter is not a recognized
  # this->field accessor"), so launch node with --expose-internals explicitly.
  postInstall = ''
    cat > "$out/bin/dsh" <<'EOF'
    #!${stdenv.shell}
    exec ${nodejs_24}/bin/node --expose-internals "${placeholder "out"}/lib/node_modules/@deepseek-ai/dsh/lib/bin.js" "$@"
    EOF
    chmod +x "$out/bin/dsh"
  '';

  meta = {
    description = "DeepSeek Harness (dsh) - open-source agent harness by DeepSeek AI";
    homepage = "https://github.com/deepseek-ai/deepseek-harness";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    mainProgram = "dsh";
  };
}
