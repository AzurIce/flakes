{
  lib,
  sources,
  appimageTools,
}:

let
  pname = "kimi-code-desktop";
  version = sources.kimi-code-desktop-x86_64-linux.version;
  src = sources.kimi-code-desktop-x86_64-linux.src;
  contents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm644 ${contents}/kimi-code.desktop ${placeholder "out"}/share/applications/kimi-code.desktop
    install -Dm644 ${contents}/usr/share/icons/hicolor/512x512/apps/kimi-code.png \
      ${placeholder "out"}/share/icons/hicolor/512x512/apps/kimi-code.png
    substituteInPlace ${placeholder "out"}/share/applications/kimi-code.desktop \
      --replace-fail "AppRun" "${placeholder "out"}/bin/kimi-code-desktop"
  '';

  meta = {
    description = "Kimi Code Desktop, the Kimi Code agent in a graphical interface";
    homepage = "https://www.kimi.com/code";
    license = lib.licenses.unfree;
    mainProgram = "kimi-code-desktop";
    platforms = [ "x86_64-linux" ];
  };
}
