{
  lib,
  stdenvNoCC,
  unzip,
  sources,
}:

let
  version = sources.splitrail-x86_64-linux.version;
  platforms = {
    x86_64-linux = "x86_64-unknown-linux-musl";
    aarch64-linux = "aarch64-unknown-linux-musl";
    x86_64-darwin = "x86_64-apple-darwin";
    aarch64-darwin = "aarch64-apple-darwin";
  };
  # Use the statically-linked musl builds on Linux so no patchelf is needed.
  src = {
    x86_64-linux = sources.splitrail-x86_64-linux.src;
    aarch64-linux = sources.splitrail-aarch64-linux.src;
    x86_64-darwin = sources.splitrail-x86_64-darwin.src;
    aarch64-darwin = sources.splitrail-aarch64-darwin.src;
  }.${stdenvNoCC.hostPlatform.system}
    or (throw "splitrail: unsupported system ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "splitrail";
  inherit version src;

  sourceRoot = "splitrail-v${version}-${platforms.${stdenvNoCC.hostPlatform.system}}";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp splitrail $out/bin/
    runHook postInstall
  '';

  meta = with lib; {
    description = "Fast, cross-platform, real-time token usage tracker and cost monitor for AI coding agents";
    homepage = "https://github.com/Piebald-AI/splitrail";
    license = licenses.mit;
    platforms = lib.platforms.darwin ++ lib.platforms.linux;
    mainProgram = "splitrail";
  };
}
