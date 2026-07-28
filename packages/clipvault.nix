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
      sha256 = "13qa9fv55h1cvs1viqsbwlp5dxa4dis8dajjkn63zzshs2qicx6i";
    };
    aarch64-linux = {
      url = "https://github.com/rolv-apneseth/clipvault/releases/download/v${version}/clipvault-aarch64-unknown-linux-gnu.tar.gz";
      sha256 = "0kbspij4pcygdfqn7yvbxnn08k8gl0jlc9l8kdv4xkzb8akqigr8";
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
