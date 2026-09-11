{
  lib,
  stdenvNoCC,
  unzip,
  sources,
}:

let
  inherit (sources.cc-switch) version src;
in
stdenvNoCC.mkDerivation {
  pname = "cc-switch";
  inherit version src;

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
