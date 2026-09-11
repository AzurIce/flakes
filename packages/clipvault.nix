{
  lib,
  stdenv,
  autoPatchelfHook,
  gcc,
  sources,
}:

let
  version = sources.clipvault-x86_64-linux.version;
  src = {
    x86_64-linux = sources.clipvault-x86_64-linux.src;
    aarch64-linux = sources.clipvault-aarch64-linux.src;
  }.${stdenv.hostPlatform.system} or (throw "clipvault: unsupported system ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "clipvault";
  inherit version src;

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
