# Paper_Tracker 面捕 / 眼追 PC 客户端。
#
# 官方没有提供可直接解包的产物：只发布一个自更新安装器，安装出来的客户端是
# Qt6 + 自带大部分依赖的约 1 GB 目录，自更新写在自己的目录里。因此这里不做纯
# Nix 打包，而是用 FHS 环境跑官方安装器，装到 $XDG_DATA_HOME/papertracker/
# 由应用自己更新；日常启动同样走 FHS，只补齐它缺失的系统库。
#
# 用法：
#   papertracker-install   首次安装 / 修复（与 Windows 相同的安装向导）
#   papertracker           启动已安装的客户端
{
  buildFHSEnv,
  fetchurl,
  runCommandLocal,
  symlinkJoin,
  writeShellScript,
  makeDesktopItem,
}:

let
  # 安装器自身版本（par tracker/setup/linux/x64/current.json），改动时同步。
  setupVersion = "0.5.5";

  setupSrc = fetchurl {
    url = "https://download-global.papertracker.top/papertracker/setup/linux/x64/PaperTrackerSetup";
    hash = "sha256-wGeEolK1Yz8kA8n8zm+o5dH2oy9fLUl/NqJiYYU10so=";
  };

  setup = runCommandLocal "papertracker-setup-${setupVersion}" { } ''
    install -Dm755 ${setupSrc} $out/bin/PaperTrackerSetup
  '';

  # 客户端自带 Qt6 / ffmpeg / OpenCV / 大部分 xcb，只缺这些系统库。
  # 少一个都会让 Qt 或 winit 启动失败，其中 winit 的报错只写
  # "Failed to load one of xlib's shared libraries"，看不出缺哪个。
  # 必须取 lib 输出：krb5 / util-linux / libdrm 的默认输出只有可执行文件。
  # e2fsprogs 例外：客户端自带的 libkrb5 要 ABI 2 的 libcom_err.so.2，
  # 而 nixpkgs krb5 只给 .so.3，得从 e2fsprogs 的 out 输出里拿。
  runtimeLibs =
    ps:
    [ (ps.lib.getOutput "out" ps.e2fsprogs) ]
    ++ map ps.lib.getLib (
      with ps;
      [
        libxcb
        libusb1
        libglvnd
        libX11
        libdrm
        util-linux
        zlib
        fontconfig
        freetype
        fribidi
        harfbuzz
        expat
        libgpg-error
        gmp
        krb5
        libXext
        libXcursor
        libXrandr
        libXi
        libXfixes
        libXrender
        libXau
        libXdmcp
        libxkbcommon
        xkeyboard-config
      ]
    );

  mkEnv =
    name: runScript:
    buildFHSEnv {
      inherit name runScript;
      targetPkgs = runtimeLibs;
    };

  # 安装器就是官方的 PaperTrackerSetup，交互与 Windows 版一致。
  installer = mkEnv "papertracker-install" "${setup}/bin/PaperTrackerSetup";

  # 与安装器使用同一个根目录（它会遵循 XDG_DATA_HOME）。
  # 官方入口是 PaperTrackerComponentLauncher --root <client> --launch：
  # 它负责自更新/修复后再启动 bin/PaperTracker，这里保持一致。
  launcher = writeShellScript "papertracker" ''
    root="''${XDG_DATA_HOME:-$HOME/.local/share}/papertracker"
    client="$root/client"
    launcher="$client/PaperTrackerComponentLauncher"

    if [ ! -x "$launcher" ]; then
      echo "PaperTracker 未安装：先运行 papertracker-install" >&2
      exit 1
    fi

    # 安装器写的 .desktop 用 ComponentLauncher 的 --maintain / --uninstall
    case "''${1:-}" in
      --maintain) exec "$launcher" --root "$client" --maintain ;;
      --uninstall) exec "$client/PaperTracker_Uninstaller" --root "$client" ;;
      *) exec "$launcher" --root "$client" --launch ;;
    esac
  '';

  runner = mkEnv "papertracker" "${launcher}";

  iconSrc = fetchurl {
    url = "https://www.papertracker.top/android-chrome-512x512.png";
    hash = "sha256-Qw1wyzOHATH19M49MOGRtYF/qs1fQQpOs7d/OZpnOwA=";
  };

  icon = runCommandLocal "papertracker-icon" { } ''
    install -Dm644 ${iconSrc} $out/share/icons/hicolor/512x512/apps/papertracker.png
  '';

  desktopItem = makeDesktopItem {
    name = "papertracker";
    desktopName = "PaperTracker";
    genericName = "VR face and eye tracking";
    comment = "Paper_Tracker 面部与眼动追踪客户端";
    exec = "${runner}/bin/papertracker %U";
    icon = "papertracker";
    categories = [ "Utility" ];
    startupWMClass = "PaperTracker";
  };
in
symlinkJoin {
  name = "papertracker-${setupVersion}";

  paths = [
    installer
    runner
    icon
    desktopItem
  ];

  meta = {
    description = "Paper_Tracker face and eye tracking client (official installer, FHS wrapper)";
    homepage = "https://www.papertracker.top/";
    platforms = [ "x86_64-linux" ];
    mainProgram = "papertracker";
  };
}
