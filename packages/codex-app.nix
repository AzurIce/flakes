{
  lib,
  stdenv,
  autoPatchelfHook,
  makeWrapper,
  dpkg,
  sources,
  # runtime closure autoPatchelf resolves against (standard Electron set)
  alsa-lib,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  gdk-pixbuf,
  glib,
  gtk3,
  libX11,
  libXcomposite,
  libXdamage,
  libXext,
  libXfixes,
  libXrandr,
  libxcb,
  libxkbcommon,
  libusb1,
  libglvnd,
  mesa,
  nspr,
  nss,
  pango,
  udev,
  gcc,
}:

let
  version = sources.codex-app-x86_64-linux.version;
in
stdenv.mkDerivation {
  pname = "codex-app";
  inherit version;
  src = sources.codex-app-x86_64-linux.src;

  # x86_64-linux only: the deb is the sole Linux distribution channel and the
  # Linux hosts in this flake are all x86_64.
  meta = {
    description = "ChatGPT / Codex desktop app by OpenAI";
    homepage = "https://developers.openai.com/codex/app";
    license = lib.licenses.unfree;
    mainProgram = "chatgpt";
    platforms = [ "x86_64-linux" ];
    hydraPlatforms = [ ];
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    gdk-pixbuf
    gcc.cc.lib
    glib
    gtk3
    libX11
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libXrandr
    libxcb
    libxkbcommon
    libusb1
    libglvnd
    mesa
    nspr
    nss
    pango
    udev
  ];

  # keep everything inside the store root so autoPatchelf can resolve the
  # bundled libs (libvips, ANGLE, .node modules) against each other
  sourceRoot = ".";
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    dpkg-deb -x "$src" unpacked
    appdir=$out/lib/chatgpt

    install -d "$out/lib"
    cp -a unpacked/usr/lib/chatgpt "$appdir"

    # prebuilds for other OSes/libcs: same-arch musl ones break autoPatchelf,
    # the rest (android/win32/darwin/arm) is dead weight on this platform
    find "$appdir" -type d -name prebuilds | while read -r dir; do
      find "$dir" -mindepth 1 -maxdepth 1 -type d ! -name 'linux-x64*' -exec rm -rf {} +
    done
    find "$appdir" -type f -name '*.musl.node' -delete

    # only dlopen'ed when running under a Qt desktop; would drag in qt5/qt6
    rm -f "$appdir"/libqt5_shim.so "$appdir"/libqt6_shim.so

    mkdir -p "$out/bin"
    makeWrapper "$appdir/ChatGPT" "$out/bin/chatgpt"

    install -Dm644 unpacked/usr/share/applications/chatgpt.desktop \
      "$out/share/applications/chatgpt.desktop"
    substituteInPlace "$out/share/applications/chatgpt.desktop" \
      --replace-fail 'Exec=chatgpt %U' 'Exec='$out/bin/chatgpt' %U'
    install -Dm644 unpacked/usr/share/pixmaps/chatgpt.png \
      "$out/share/icons/hicolor/1024x1024/apps/chatgpt.png"
    install -Dm644 unpacked/usr/share/metainfo/com.openai.chatgpt.metainfo.xml \
      "$out/share/metainfo/com.openai.chatgpt.metainfo.xml"

    runHook postInstall
  '';
}
