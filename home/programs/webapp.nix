{ pkgs, ... }:

# webapp: 以独立的 chromium app 窗口打开一个 URL（无标签栏/地址栏）。
# - 每个应用有独立的 user-data-dir（登录态隔离），窗口 class 为 webapp-<name>，
#   方便 Hyprland windowrule 单独管理。
# - 无参数时弹 rofi 输入 URL，因此也可以作为 drun 入口使用。
let
  webapp = pkgs.writeShellScriptBin "webapp" ''
    set -e

    url="''${1:-}"

    # 无参数：弹 rofi 输入 URL
    if [ -z "$url" ]; then
      url="$(${pkgs.rofi}/bin/rofi -dmenu -p 'webapp')"
    fi
    [ -z "$url" ] && exit 0

    # 缺协议时补 http://
    case "$url" in
      *://*) ;;
      *) url="http://$url" ;;
    esac

    # 应用名默认取 host[-port]（第二个参数可覆盖）
    name="''${2:-}"
    if [ -z "$name" ]; then
      host="''${url#*://}"
      host="''${host%%/*}"
      name="$(echo "$host" | tr ':' '-')"
    fi

    exec ${pkgs.chromium}/bin/chromium \
      --app="$url" \
      --user-data-dir="''${XDG_DATA_HOME:-$HOME/.local/share}/webapps/$name" \
      --class="webapp-$name" \
      --no-first-run \
      --no-default-browser-check
  '';
in
{
  home.packages = [ webapp ];

  # drun 入口：无参数启动 webapp，弹出 rofi 输入 URL
  xdg.desktopEntries.webapp = {
    name = "Web App";
    genericName = "Site-specific Browser";
    comment = "Open a URL in a dedicated chromium app window";
    exec = "${webapp}/bin/webapp";
    icon = "applications-internet";
    categories = [ "Network" ];
    terminal = false;
  };
}
