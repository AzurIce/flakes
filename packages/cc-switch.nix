{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:

let
  version = "3.11.1";
in
stdenvNoCC.mkDerivation {
  pname = "cc-switch";
  inherit version;

  src = fetchurl {
    url = "https://github.com/farion1231/cc-switch/releases/download/v${version}/CC-Switch-v${version}-macOS.zip";
    hash = "sha256-ZrLGANiAwTQ82JqJxP+8VyIWL/l0vV4W6l8rlJl08F0=";
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
