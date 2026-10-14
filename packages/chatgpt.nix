{
  lib,
  stdenv,
  sources,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  gdk-pixbuf,
  git,
  glib,
  gtk3,
  libX11,
  libXcomposite,
  libXdamage,
  libXext,
  libXfixes,
  libXrandr,
  libdrm,
  libgbm,
  libglvnd,
  libnotify,
  libusb1,
  libxcb,
  libxkbcommon,
  mesa,
  nspr,
  nss,
  openssl,
  pango,
  systemdLibs,
  tpm2-tss,
  vulkan-loader,
  xdg-utils,
  xz,
}:

let
  version = sources.chatgpt-x86_64-linux.version;
  src = {
    x86_64-linux = sources.chatgpt-x86_64-linux.src;
    aarch64-linux = sources.chatgpt-aarch64-linux.src;
  }.${stdenv.hostPlatform.system}
    or (throw "chatgpt: unsupported system ${stdenv.hostPlatform.system}");
in
# The deb's postinst only registers OpenAI's apt repo for self-updates; here
# updates come from nvfetcher, so it (and the apparmor profile) is dropped.
# No chrome-sandbox is shipped upstream; Electron falls back to user
# namespaces, which NixOS enables by default.
stdenv.mkDerivation {
  pname = "chatgpt";
  inherit version src;

  # autoPatchelf moves PT_INTERP beyond detect-libc's 2 KiB scan window, so
  # @parcel/watcher's loader falls back to process.report.getReport(), which
  # trips Electron's CFI (SIGILL in git-worker threads). Force the glibc
  # backend instead; the sed is length-preserving to keep asar offsets valid.
  # https://github.com/NixOS/nixpkgs/commit/8917735c8596eb80ea5be8b2f4a02fd6b246041c
  postPatch = ''
    sed -i "s|const family = familySync();|const family = 'glibc'     ;|" \
      usr/lib/chatgpt/resources/app.asar
  '';

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
  ];

  # Qt shims are dlopen'd only for KDE integration, and the musl .node
  # prebuilds are unused on glibc systems (the glibc variants patch fine).
  autoPatchelfIgnoreMissingDeps = [
    "libQt5Core.so.5"
    "libQt5Gui.so.5"
    "libQt5Widgets.so.5"
    "libQt6Core.so.6"
    "libQt6Gui.so.6"
    "libQt6Widgets.so.6"
    "libc.musl-x86_64.so.1"
    "libc.musl-aarch64.so.1"
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    gdk-pixbuf
    glib
    gtk3
    libX11
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libXrandr
    libdrm
    libgbm
    libglvnd
    libnotify
    libusb1
    libxcb
    libxkbcommon
    mesa
    nspr
    nss
    openssl
    pango
    stdenv.cc.cc.lib
    systemdLibs
    tpm2-tss
    vulkan-loader
  ];

  # libGL/libEGL/libvulkan are dlopen'd by ANGLE at runtime, so they never
  # appear as NEEDED entries; runtimeDependencies appends them to the RPATH
  # unconditionally. The actual drivers then resolve through glvnd into
  # NixOS's /run/opengl-driver.
  runtimeDependencies = [
    libglvnd
    mesa
    vulkan-loader
  ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x "$src" unpacked
    sourceRoot=unpacked
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib
    cp -r usr/lib/chatgpt $out/lib/chatgpt

    # Upstream's /usr/bin/chatgpt is a shell launcher resolving ChatGPT next
    # to itself; replace it with a proper wrapper. git and xdg-utils are
    # runtime deps (Codex drives git; links open via xdg-open).
    makeWrapper $out/lib/chatgpt/ChatGPT $out/bin/chatgpt \
      --prefix PATH : ${
        lib.makeBinPath [
          git
          xdg-utils
          xz
        ]
      }

    install -Dm444 usr/share/applications/chatgpt.desktop $out/share/applications/chatgpt.desktop
    substituteInPlace $out/share/applications/chatgpt.desktop \
      --replace-fail "Exec=chatgpt %U" "Exec=$out/bin/chatgpt %U"
    install -Dm444 usr/share/pixmaps/chatgpt.png $out/share/pixmaps/chatgpt.png

    runHook postInstall
  '';

  meta = {
    description = "ChatGPT desktop app (includes Codex)";
    homepage = "https://chatgpt.com/download";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "chatgpt";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
