{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:

let
  version = "3.7.2";
  assets = {
    "aarch64-darwin" = {
      platform = "aarch64-apple-darwin";
      hash = "sha256-FCD/7cBpHXQZ6iB2hc9jQBpKuyvbJKuza8ofAMHJTZI=";
    };
    "x86_64-darwin" = {
      platform = "x86_64-apple-darwin";
      hash = "sha256-2EAX1mIDht9objgOp8mg3PZbRkPYXqM0F8cqEbcP95Y=";
    };
    # Use the statically-linked musl builds on Linux so no patchelf is needed.
    "x86_64-linux" = {
      platform = "x86_64-unknown-linux-musl";
      hash = "sha256-Ft/jReBc23vqoh7NsBWxg5O1J/7qAOMO+t6EZyqvR3Q=";
    };
    "aarch64-linux" = {
      platform = "aarch64-unknown-linux-musl";
      hash = "sha256-ZFv4otUPacISy8l98K7Y6W1P3cweez7NFr1HJFwDYbU=";
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
