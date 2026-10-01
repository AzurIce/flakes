# DeepSeek Harness (dsh) — open-source agent harness by DeepSeek AI
# https://github.com/deepseek-ai/deepseek-harness
#
# Adapted from https://github.com/chinrw/deepseek-harness-nix (MIT), which
# tracks the nixpkgs PR NixOS/nixpkgs#552467. Tracks the npm `next`
# dist-tag of @deepseek-ai/dsh (upstream froze the `alpha` tag at
# 0.1.7-alpha.2 and moved previews to `next`; flip the regex in
# packages/nvfetcher.toml to re-track stable `latest`); update with
# `just update` (version + src) and `just update-dsh` (lockfile + hash).

{ lib
, stdenv
, buildNpmPackage
, nodejs_24
, python3
, jq
, sources
}:

let
  inherit (sources.dsh) version src;
  npmDepsHash = "sha256-DFwzW3SkYtpi+w8YTfFUEb3HRTjWBSKI5cRzF83b/v8=";
in
(buildNpmPackage.override { nodejs = nodejs_24; }) {
  pname = "deepseek-harness";
  inherit version npmDepsHash src;

  # The npm tarball unpacks into a top-level `package/` directory (the old
  # fetchzip-based src stripped it implicitly).
  sourceRoot = "package";

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

  # dsh-app-boot loads Node internal modules exclusively through the
  # node-addon-require-builtin native addon, whose prebuild pokes at V8
  # internals and fails on this Node ("x64 sysv getter is not a recognized
  # this->field accessor"). The wrapper below launches node with
  # --expose-internals, so patch the call sites to prefer plain require()
  # and keep the addon only as a fallback (the strategy cordis-plugin-loader
  # already implements on its own).
  preBuild = ''
    while IFS= read -r f; do
      substituteInPlace "$f" --replace-fail \
        'const addon = createRequire(import.meta.url)("node-addon-require-builtin");' \
        'const addon = ((req) => ({ requireBuiltin(id) { if (process.execArgv.includes("--expose-internals")) try { return req(id); } catch {} return req("node-addon-require-builtin").requireBuiltin(id); } }))(createRequire(import.meta.url));'
    done < <(grep -rlF --include='*.js' 'createRequire(import.meta.url)("node-addon-require-builtin")' node_modules)
  '';

  # Node internals must be exposed for the patched requireBuiltin above.
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
