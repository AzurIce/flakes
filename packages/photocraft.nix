{
  lib,
  stdenv,
  autoPatchelfHook,
  makeWrapper,
  gcc,
  dbus,
  fontconfig,
  libglvnd,
  libx11,
  libxcb,
  libxcursor,
  libxi,
  libxrandr,
  libxkbcommon,
  vulkan-loader,
  wayland,
  xdg-utils,
  sources,
}:

let
  source = sources."photocraft-${stdenv.hostPlatform.system}";
  runtimeLibs = [
    dbus
    fontconfig
    libglvnd
    libx11
    libxcb
    libxcursor
    libxi
    libxrandr
    libxkbcommon
    vulkan-loader
    wayland
  ];
in
stdenv.mkDerivation {
  pname = "photocraft";
  inherit (source) version src;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];
  buildInputs = [ gcc.cc.lib ];

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r bin share $out/
    substituteInPlace $out/share/applications/ai.storyteller.photocraft.desktop \
      --replace-fail "Exec=photocraft %F" "Exec=$out/bin/photocraft %F" \
      --replace-fail "TryExec=photocraft" "TryExec=$out/bin/photocraft"
    runHook postInstall
  '';

  postFixup = ''
    # Include dlopen dependencies in child processes' library search paths too.
    for program in photocraft photocraft-cli; do
      wrapProgram $out/bin/$program \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs} \
        --prefix PATH : ${lib.makeBinPath [ xdg-utils ]}
    done
  '';

  meta = {
    description = "Native image editor with layers, masks, and PSD support";
    homepage = "https://github.com/storytold/photocraft";
    license = with lib.licenses; [
      mit
      asl20
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "photocraft";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
