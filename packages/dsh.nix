# DeepSeek Harness (dsh) — open-source agent harness by DeepSeek AI
# https://github.com/deepseek-ai/deepseek-harness
#
# Adapted from https://github.com/chinrw/deepseek-harness-nix (MIT), which
# tracks the nixpkgs PR NixOS/nixpkgs#552467. Tracks the npm `latest` dist-tag
# of @deepseek-ai/dsh; update with `just update` (version + src) and
# `just update-dsh` (vendored lockfile + npmDepsHash).

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
  npmDepsHash = "sha256-U8nbFGNVYxInNKo/sSKPXi57tbaw5DmpbcWmXpY4V/s=";
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

  # The shipped `node-addon-require-builtin` prebuild cannot probe nixpkgs'
  # Node binary ("x64 sysv getter is not a recognized this->field accessor"),
  # so Node internals must come from plain require with --expose-internals
  # (see postInstall). Most packages try require first and only fall back to
  # the addon; dsh-app-boot's internalModules() uses the addon unconditionally
  # and is patched here to do the same.
  preInstall = ''
    node <<'EOF'
    const fs = require("fs");
    const path = require("path");
    const before = "\tconst addon = createRequire(import.meta.url)(\"node-addon-require-builtin\");";
    const after = "\tconst __dshRequire = createRequire(import.meta.url);\n\tconst addon = { requireBuiltin: (id) => { try { return __dshRequire(id); } catch { return __dshRequire(\"node-addon-require-builtin\").requireBuiltin(id); } } };";
    const targets = [];
    (function walk(dir) {
      for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
        const p = path.join(dir, entry.name);
        if (entry.isDirectory()) walk(p);
        else if (/dsh-app-boot\/lib\/(index\.js|worker\/profile-resolution-bootstrap\.js)$/.test(p)) targets.push(p);
      }
    })("node_modules");
    if (targets.length === 0) throw new Error("dsh-app-boot not found under node_modules");
    for (const file of targets) {
      const text = fs.readFileSync(file, "utf8");
      if (!text.includes(before)) throw new Error("internalModules pattern not found in " + file);
      fs.writeFileSync(file, text.replace(before, after));
      console.log("patched internalModules in " + file);
    }
    EOF
  '';

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
