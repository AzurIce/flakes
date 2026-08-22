{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:

let
  version = "3.7.1";
  assets = {
    "aarch64-darwin" = {
      platform = "aarch64-apple-darwin";
      hash = "sha256-Zy5KWayxFCxnNRh6EvPhyDsH9Gi94hpoWcUyFxrV1iI=";
    };
    "x86_64-darwin" = {
      platform = "x86_64-apple-darwin";
      hash = "sha256-4+LChNW6DtDmZZVSBRDQuSXwQvMxMxzU9dEidwhFL0c=";
    };
    # Use the statically-linked musl builds on Linux so no patchelf is needed.
    "x86_64-linux" = {
      platform = "x86_64-unknown-linux-musl";
      hash = "sha256-Kih4380XBlaG6HvjCHhIEaeVa1RVb8eCYKshVaxgVxI=";
    };
    "aarch64-linux" = {
      platform = "aarch64-unknown-linux-musl";
      hash = "sha256-xZ2am/tnB9Gt3KRNysM+EPa1gKJftc4AjZs1u1m7b2w=";
    };
  };
  asset =
    assets.${stdenvNoCC.hostPlatform.system}
      or (throw "Unsupported platform: ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "splitrail";
  inherit version;

  src = fetchurl {
    url = "https://github.com/Piebald-AI/splitrail/releases/download/v${version}/splitrail-v${version}-${asset.platform}.tar.gz";
    inherit (asset) hash;
  };

  sourceRoot = "splitrail-v${version}-${asset.platform}";

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
    platforms = platforms.darwin ++ platforms.linux;
    mainProgram = "splitrail";
  };
}
