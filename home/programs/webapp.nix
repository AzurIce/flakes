{ pkgs, ... }:

# 本机/局域网 URL 用普通 Chromium 打开，外网 URL 交给 Vivaldi。
let
  # 非本机地址交给它。不要写成 xdg-open：那会再次命中本 router，造成递归。
  fallbackBrowser = "vivaldi";

  # URL 分流器：本机/局域网地址 → Chromium，其余 → fallbackBrowser。
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
        ;;
      *:*)
        host="''${authority%%:*}"
        ;;
      *)
        host="$authority"
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

    exec ${pkgs.chromium}/bin/chromium "$url"
  '';
in
{
  home.packages = [
    router
  ];

  # URL 打开事件走这个 handler，而不是直接起 vivaldi
  xdg.desktopEntries.webapp-router = {
    name = "Browser Router";
    comment = "Local URLs in Chromium, other URLs in Vivaldi";
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
