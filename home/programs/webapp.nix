{ pkgs, ... }:

# webapp: 以独立的 chromium app 窗口打开一个 URL（无标签栏/地址栏）。
# - 每个应用有独立的 user-data-dir（登录态隔离），窗口 class 为 webapp-<name>，
#   方便 Hyprland windowrule 单独管理。
# - 无参数时弹 rofi 输入 URL，因此也可以作为 drun 入口使用。
#
# webapp-router: URL 分流器，替代"手动开 webapp 再输地址"。它同时是
#   - x-scheme-handler/http(s) 的默认 handler（本文件末尾注册，覆盖 xdg-open、
#     gio open、以及 dsh web 内置的 open/xdg-open 这类调用），
#   - $BROWSER 的值（覆盖 python -m webbrowser、git web--browse 等只读变量的程序）。
# 于是 dsh web / jupyter / vite 之类"自己叫浏览器"的程序里，凡是本机或局域网
# 地址都自动开成 webapp 窗口，外网地址照旧交给 fallbackBrowser。
#
# 窗口名（同时是 user-data-dir 名）默认取 host-port，可在
# ~/.config/webapp/router.conf 里覆盖，例如让 3080 端口叫 dsh：
#   3080 = dsh
let
  # 非本机地址交给它。不要写成 xdg-open：那会再次命中本 router，造成递归。
  fallbackBrowser = "vivaldi";

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

  # URL 分流器：本机/局域网地址 → webapp 窗口，其余 → fallbackBrowser。
  # 调用方可能是 xdg-open（传 URL）、gio（传 URL）、$BROWSER 消费者，参数都是 URL。
  router = pkgs.writeShellScriptBin "webapp-router" ''
    set -euo pipefail

    url="''${1:-}"
    [ -n "$url" ] || exit 0

    # 只接管 http(s)；file://、mailto: 之类原样交给 fallback 浏览器
    case "$url" in
      http://*|https://*|HTTP://*|HTTPS://*) ;;
      *) exec ${fallbackBrowser} "$url" ;;
    esac

    # 取 authority（[user@]host[:port]），丢掉 path / query / fragment / userinfo
    rest="''${url#*://}"
    authority="''${rest%%/*}"
    authority="''${authority%%\?*}"
    authority="''${authority%%#*}"
    authority="''${authority##*@}"
    case "$authority" in
      \[*\]*)
        # IPv6 字面量：先剥掉 [ ]，再取端口
        host="''${authority%%]*}"
        host="''${host#\[}"
        port="''${authority#*]}"
        port="''${port#:}"
        ;;
      *:*)
        host="''${authority%%:*}"
        port="''${authority##*:}"
        ;;
      *)
        host="$authority"
        port=""
        ;;
    esac
    host="$(printf '%s' "$host" | tr '[:upper:]' '[:lower:]')"

    case "$host" in
      localhost|127.*|0.0.0.0|::1|*.localhost|*.local|*.lan|*.internal|10.*|192.168.*|169.254.*|172.1[6-9].*|172.2[0-9].*|172.3[01].*)
        : ;;
      *.*)
        exec ${fallbackBrowser} "$url" ;;
      *)
        # 不含点的裸主机名：当作 mDNS / 局域网机器名
        : ;;
    esac

    # 可选的窗口名映射：每行 key = name，# 开头为注释；
    # key 可以是 host:port、port 或 host，优先级依次降低。
    name=""
    conf="''${XDG_CONFIG_HOME:-$HOME/.config}/webapp/router.conf"
    if [ -r "$conf" ]; then
      name="$(awk -F= -v k1="$host:$port" -v k2="$port" -v k3="$host" '
        /^[[:space:]]*#/ { next }
        {
          k = $1; v = $2
          gsub(/[[:space:]]/, "", k)
          gsub(/[[:space:]]/, "", v)
          if (v == "") next
          if (k == k1) one = v
          else if (k == k2) two = v
          else if (k == k3) three = v
        }
        END {
          if (one != "") print one
          else if (two != "") print two
          else if (three != "") print three
        }
      ' "$conf")"
    fi

    if [ -z "$name" ]; then
      if [ -n "$port" ]; then name="$host-$port"; else name="$host"; fi
    fi

    exec "${webapp}/bin/webapp" "$url" "$name"
  '';
in
{
  home.packages = [
    webapp
    router
  ];

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

  # URL 打开事件走这个 handler，而不是直接起 vivaldi
  xdg.desktopEntries.webapp-router = {
    name = "Web App Router";
    comment = "Local URLs in a chromium app window, other URLs in the default browser";
    exec = "${router}/bin/webapp-router %u";
    icon = "applications-internet";
    categories = [ "Network" ];
    mimeType = [
      "x-scheme-handler/http"
      "x-scheme-handler/https"
    ];
    # 只在被 URL 触发时使用，不出现在启动器里
    noDisplay = true;
    terminal = false;
  };

  # text/html（本地 html 文件）、about:、unknown 仍由 hyprland/default.nix 指向 vivaldi
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/http" = "webapp-router.desktop";
      "x-scheme-handler/https" = "webapp-router.desktop";
    };
  };

  # 只读 $BROWSER 的程序也走同一套分流
  home.sessionVariables.BROWSER = "webapp-router";
}
