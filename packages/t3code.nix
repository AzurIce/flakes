# T3 Code — desktop control plane for coding agents (https://t3.codes/)
#
# Linux builds are Electron apps shipped as .deb (plus AppImage); the deb is
# the better fit here because its native modules get patchelf'd like any other
# Electron package. Version + src come from packages/nvfetcher.toml (`just
# update`), one entry per platform deb; the GitHub release also carries
# `-nightly.*` tags, which are marked prerelease so nvfetcher ignores them.
#
# The app resolves app.asar, its bundled server (resources/server-compile-cache)
# and the native agent helpers relative to the executable, so the whole tree
# stays together under libexec/ and $out/bin/t3code is just a wrapper that adds
# git/xdg-utils to PATH. The in-app updater cannot write into the store — bump
# the flake instead.

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
  libsecret,
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
}:

let
  version = sources.t3code-x86_64-linux.version;
  src =
    {
      x86_64-linux = sources.t3code-x86_64-linux.src;
      aarch64-linux = sources.t3code-aarch64-linux.src;
    }
    .${stdenv.hostPlatform.system}
      or (throw "t3code: unsupported system ${stdenv.hostPlatform.system}");

  # node-pty prebuild directory names (both arches are bundled in each deb).
  nodeArch =
    {
      x86_64-linux = "x64";
      aarch64-linux = "arm64";
    }
    .${stdenv.hostPlatform.system};
in
stdenv.mkDerivation {
  pname = "t3code";
  inherit version src;

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
  ];

  # The musl prebuilds are dead weight on glibc; their linker name is not in
  # the store. Qt shims are dlopen'd only for KDE integration.
  autoPatchelfIgnoreMissingDeps = [
    "libc.musl-x86_64.so.1"
    "libc.musl-aarch64.so.1"
    "libc.so"
    "libQt5Core.so.5"
    "libQt5Gui.so.5"
    "libQt5Widgets.so.5"
    "libQt6Core.so.6"
    "libQt6Gui.so.6"
    "libQt6Widgets.so.6"
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
    libnotify
    libsecret
    libusb1
    libxcb
    libxkbcommon
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
  # unconditionally. Drivers then resolve through glvnd into /run/opengl-driver.
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

    mkdir -p $out/libexec
    cp -r "opt/T3 Code (Beta)" $out/libexec/t3code

    # patchelf cannot safely rewrite the other architecture's prebuild.
    rm -rf "$out/libexec/t3code/resources/app.asar.unpacked/node_modules/node-pty/prebuilds/linux-${
      if nodeArch == "x64" then "arm64" else "x64"
    }"

    makeWrapper $out/libexec/t3code/t3code $out/bin/t3code \
      --prefix PATH : ${
        lib.makeBinPath [
          git
          xdg-utils
        ]
      }

    install -Dm444 usr/share/applications/t3code.desktop $out/share/applications/t3code.desktop
    substituteInPlace $out/share/applications/t3code.desktop \
      --replace-fail 'Exec="/opt/T3 Code (Beta)/t3code" %U' "Exec=$out/bin/t3code %U"

    cp -r usr/share/icons $out/share/icons
    install -Dm444 usr/share/metainfo/com.t3tools.t3code.metainfo.xml \
      $out/share/metainfo/com.t3tools.t3code.metainfo.xml

    runHook postInstall
  '';

  meta = {
    description = "T3 Code, an open-source desktop app for coding agents";
    homepage = "https://t3.codes/";
    changelog = "https://github.com/pingdotgg/t3code/releases/tag/v${version}";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "t3code";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
