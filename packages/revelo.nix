{
  lib,
  stdenvNoCC,
  sources,
}:

let
  inherit (sources.revelo) version src;
in
stdenvNoCC.mkDerivation {
  pname = "revelo";
  inherit version src;

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
