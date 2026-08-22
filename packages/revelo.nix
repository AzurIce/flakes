{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:

let
  version = "0.5.5";
  hash = "sha256-wYXs6lZxqUcRJXGUJzopqdwRQx7m9S8z2Rz3TsPghB0=";
  platform =
    if stdenvNoCC.hostPlatform.isAarch64 then "aarch64-apple-darwin" else throw "Unsupported platform";
in
stdenvNoCC.mkDerivation {
  pname = "revelo";
  inherit version;

  src = fetchurl {
    url = "https://github.com/vbasky/revelo/releases/download/v${version}/revelo-v${version}-${platform}.tar.gz";
    inherit hash;
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp revelo $out/bin/
    runHook postInstall
  '';

  meta = with lib; {
    description = "A safe, fast Rust port of MediaInfoLib";
    homepage = "https://github.com/vbasky/revelo";
    license = licenses.mit;
    platforms = platforms.darwin;
    mainProgram = "revelo";
  };
}
