{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  gcc,
}:

let
  version = "1.3.0";
  sources = {
    x86_64-linux = {
      url = "https://github.com/rolv-apneseth/clipvault/releases/download/v${version}/clipvault-x86_64-unknown-linux-gnu.tar.gz";
      sha256 = "sha256-0XQWsdBQ/z+MnVKqhnRsRPVWLuVL47iD3izAUrZLCo8=";
    };
    aarch64-linux = {
      url = "https://github.com/rolv-apneseth/clipvault/releases/download/v${version}/clipvault-aarch64-unknown-linux-gnu.tar.gz";
      sha256 = "sha256-KL+Ip0Lrz052m4gmRiWgD00ErO1r+2Oxa8+zS2S8ek0=";
    };
  };
  source = sources.${stdenv.hostPlatform.system} or (throw "clipvault: unsupported system ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "clipvault";
  inherit version;

  src = fetchurl {
    inherit (source) url sha256;
  };

  sourceRoot = ".";

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [ gcc.cc.lib ];

  installPhase = ''
    runHook preInstall
    install -Dm755 clipvault $out/bin/clipvault
    runHook postInstall
  '';

  meta = {
    description = "Clipboard history manager for Wayland, inspired by cliphist";
    homepage = "https://github.com/rolv-apneseth/clipvault";
    license = lib.licenses.agpl3Only;
    maintainers = [ ];
    mainProgram = "clipvault";
    platforms = [ "x86_64-linux" "aarch64-linux" ];
  };
}
