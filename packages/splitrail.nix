{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:

let
  version = "3.3.3";
  hash = "sha256-ZVzLaBO/kjwjefwSyI8r8otHskBMsp4mvSzDHc6d5xU=";
  platform =
    if stdenvNoCC.hostPlatform.isAarch64 then
      "aarch64-apple-darwin"
    else if stdenvNoCC.hostPlatform.isx86_64 then
      "x86_64-apple-darwin"
    else
      throw "Unsupported platform";
in
stdenvNoCC.mkDerivation {
  pname = "splitrail";
  inherit version;

  src = fetchurl {
    url = "https://github.com/Piebald-AI/splitrail/releases/download/v${version}/splitrail-v${version}-${platform}.tar.gz";
    inherit hash;
  };

  sourceRoot = "splitrail-v${version}-${platform}";

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
    platforms = platforms.darwin;
    mainProgram = "splitrail";
  };
}
