# REA — Reverse Engineer Anything (CLI + MCP server).
# Tracks npm's latest dist-tag through nvfetcher; update with `just update`
# (version + src) and `just update-rea` (vendored lockfile + npmDepsHash).
{
  lib,
  stdenv,
  buildNpmPackage,
  nodejs_24,
  python3,
  jq,
  autoPatchelfHook,
  sources,
}:

let
  inherit (sources.rea) version src;
  npmDepsHash = "sha256-aMD66LEDaVjyDrdaaSQA2FjdAUltdj+RZH8W8xNIdNo=";
in
(buildNpmPackage.override { nodejs = nodejs_24; }) {
  pname = "rea-agents";
  inherit version src npmDepsHash;
  sourceRoot = "package";

  nativeBuildInputs = [ python3 ] ++ lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ stdenv.cc.cc.lib ];

  # The published tarball already contains dist/ and the matching skill, but
  # no lockfile. Mirror update-rea.sh's manifest before installing dependencies.
  # jq's absolute path also works inside the fetchNpmDeps derivation.
  postPatch = ''
    ${jq}/bin/jq 'del(.devDependencies)' package.json > package.json.new
    mv package.json.new package.json
    cp ${./rea-package-lock.json} package-lock.json
  '';

  dontNpmBuild = true;

  postInstall = ''
    mkdir -p "$out/share/rea"
    ln -s "$out/lib/node_modules/rea-agents/skills" "$out/share/rea/skills"
  '';

  meta = {
    description = "Reverse engineer applications and binaries with a CLI and MCP server";
    homepage = "https://github.com/morluto/rea";
    license = lib.licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    mainProgram = "rea";
  };
}
