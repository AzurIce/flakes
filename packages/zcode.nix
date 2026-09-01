{
  lib,
  appimageTools,
  fetchurl,
}:

let
  pname = "zcode";
  version = "3.10.1";
  src = fetchurl {
    url = "https://cdn-zcode.z.ai/zcode/electron/releases/${version}/linux-x64/ZCode-${version}-linux-x64.AppImage";
    hash = "sha256-9T/d0uf3roTimyZgy0oMaHyUmdZbmKdOIifAAWdOI1o=";
  };
  contents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  pname = "zcode";
  inherit version;
  inherit src;

  extraInstallCommands = ''
    install -Dm644 ${contents}/zcode.desktop ${placeholder "out"}/share/applications/zcode.desktop
    install -Dm644 ${contents}/resources/icon_512x512.png ${placeholder "out"}/share/icons/hicolor/512x512/apps/zcode.png
    substituteInPlace ${placeholder "out"}/share/applications/zcode.desktop \
      --replace-fail "AppRun" "${placeholder "out"}/bin/zcode"
  '';

  meta = {
    description = "ZCode Desktop, an agentic development environment powered by GLM";
    homepage = "https://zcode.z.ai";
    license = lib.licenses.unfree;
    mainProgram = "zcode";
    platforms = [ "x86_64-linux" ];
  };
}
