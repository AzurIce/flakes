{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:

let
  version = "3.6.1";
  assets = {
    "aarch64-darwin" = {
      platform = "aarch64-apple-darwin";
      hash = "sha256-QyRFdQfLE95c4RGAVSdSMQYqf/PT4YKkKUNQx6WIcGE=";
    };
    "x86_64-darwin" = {
      platform = "x86_64-apple-darwin";
      hash = "sha256-KPpjwOvc7WJpMCV+efDXKui5px5v808vxEXo6R3aa2M=";
    };
    # Use the statically-linked musl builds on Linux so no patchelf is needed.
    "x86_64-linux" = {
      platform = "x86_64-unknown-linux-musl";
      hash = "sha256-pDKi81OstcyvVQvHEGPZjjvtBG90gbhI4s/aLiIkmt8=";
    };
    "aarch64-linux" = {
      platform = "aarch64-unknown-linux-musl";
      hash = "sha256-qrTLtEhlRM/hc8KtWpUAo0SVeNKTCcQx6A/k8JyVeJQ=";
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
