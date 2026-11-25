# RAD Debugger — native, user-mode, multi-process graphical debugger (x64 Linux).
# Upstream ships a hand-rolled build.sh rather than a standard build system, so
# the derivation drives it directly and installs the single build/raddbg binary.
# Version + src come from nvfetcher (packages/nvfetcher.toml); `just update`.
{
  lib,
  stdenv,
  clang,
  llvm,
  pkg-config,
  makeWrapper,
  freetype,
  libx11,
  libxext,
  libxfixes,
  libxrandr,
  libGL,
  zenity,
  sources,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "raddbg";
  inherit (sources.raddbg) version src;

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];
  buildInputs = [
    freetype
    libx11
    libxext
    libxfixes
    libxrandr
    libGL
  ];

  # The tagged build.sh stamps `git describe`/`git rev-parse` into the binary,
  # which a source tarball cannot provide. Stamp the release tag instead.
  postPatch = ''
    substituteInPlace build.sh \
      --replace-fail 'git_hash=$(git describe --always --dirty)' 'git_hash=${finalAttrs.version}' \
      --replace-fail 'git_hash_full=$(git rev-parse HEAD)' 'git_hash_full=${finalAttrs.version}'
  '';

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild
    export CC="${clang}/bin/clang"
    export AR="${llvm}/bin/llvm-ar"
    bash ./build.sh release raddbg
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 build/raddbg $out/bin/raddbg
    runHook postInstall
  '';

  # The windowing layer is X11-only, so EGL must match it; a Wayland session
  # exports EGL_PLATFORM=wayland, and NVIDIA's EGL-Wayland path segfaults when
  # handed the debugger's X11 display. Pin it. zenity backs the file picker and
  # the `--help` window, which have no fallback.
  postInstall = ''
    wrapProgram $out/bin/raddbg \
      --set EGL_PLATFORM x11 \
      --suffix PATH : ${lib.makeBinPath [ zenity ]}
  '';

  meta = {
    description = "RAD Debugger, a native multi-process graphical debugger";
    homepage = "https://github.com/EpicGames/raddebugger";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "raddbg";
  };
})
