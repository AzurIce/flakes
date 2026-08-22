{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:

let
  version = "3.20.0";
in
stdenvNoCC.mkDerivation {
  pname = "cc-switch";
  inherit version;

  src = fetchurl {
    url = "https://github.com/farion1231/cc-switch/releases/download/v${version}/CC-Switch-v${version}-macOS.zip";
    hash = "sha256-MlHTsuQtyhRcMn1y8u/pV0CDFL1B3pTdc0bT/KHvg7Q=";
  };

  nativeBuildInputs = [ unzip ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    cp -r *.app $out/Applications/
    runHook postInstall
  '';

  meta = with lib; {
    description = "All-in-One assistant tool for Claude Code, Codex, OpenCode & Gemini CLI";
    homepage = "https://github.com/farion1231/cc-switch";
    license = licenses.mit;
    platforms = platforms.darwin;
  };
}
