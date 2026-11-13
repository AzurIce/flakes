{
  config,
  lib,
  pkgs,
  ...
}:
let
  caddyBase = pkgs.caddy.withPlugins {
    plugins = [ "github.com/caddy-dns/duckdns@v0.5.0" ];
    hash = "sha256-1nx8y8vrE3MubRMqviM5mYqCK3d0SLkXI0Ts8eWBmdc=";
  };
  caddy = caddyBase.overrideAttrs (old: {
    src = old.src.overrideAttrs (source: {
      buildPhase = ''
        export GOPROXY=https://goproxy.cn,direct
      ''
      + source.buildPhase;
    });
  });
  credentials = "${config.xdg.configHome}/caddy/duckdns.token";
  logDir = "${config.xdg.dataHome}/caddy/logs";
  updateDns = pkgs.writeShellScript "celestite-duckdns-update" ''
    set -eu
    umask 077
    DUCKDNS_API_TOKEN=$(cat ${lib.escapeShellArg credentials})
    case "$DUCKDNS_API_TOKEN" in
      ""|*[!a-zA-Z0-9-]*) echo "Invalid DuckDNS token file" >&2; exit 1 ;;
    esac
    # Send credentials through stdin, keeping them out of process arguments.
    celestite_dns_result=$(${pkgs.curl}/bin/curl --config - <<EOF
    url = "https://www.duckdns.org/update?domains=azurice&token=$DUCKDNS_API_TOKEN&ip="
    silent
    show-error
    fail
    ipv4
    noproxy = "*"
    connect-timeout = 15
    max-time = 45
    EOF
    )
    test "$celestite_dns_result" = OK || {
      echo "DuckDNS update failed" >&2
      exit 1
    }
  '';
  runCaddy = pkgs.writeShellScript "celestite-caddy-start" ''
    set -eu
    umask 077
    DUCKDNS_API_TOKEN=$(cat ${lib.escapeShellArg credentials})
    export DUCKDNS_API_TOKEN
    test -n "$DUCKDNS_API_TOKEN"
    exec ${caddy}/bin/caddy run \
      --config ${lib.escapeShellArg "${config.xdg.configHome}/caddy/Caddyfile"} --adapter caddyfile
  '';
in
{
  home.packages = [ caddy ];
  xdg.configFile."caddy/Caddyfile".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/flakes/.dotfiles/caddy/Caddyfile";

  home.activation.celestiteCaddyDirectories = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p ${lib.escapeShellArg logDir}
  '';

  launchd.agents.caddy = {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.bash}/bin/bash"
        "${runCaddy}"
      ];
      EnvironmentVariables = {
        XDG_DATA_HOME = config.xdg.dataHome;
        XDG_CONFIG_HOME = config.xdg.configHome;
      };
      RunAtLoad = true;
      KeepAlive = true;
      ThrottleInterval = 30;
      StandardOutPath = "${logDir}/caddy.log";
      StandardErrorPath = "${logDir}/caddy.error.log";
    };
  };

  launchd.agents.celestite-duckdns = {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.bash}/bin/bash"
        "${updateDns}"
      ];
      RunAtLoad = true;
      StartInterval = 300;
      StandardOutPath = "${logDir}/duckdns.log";
      StandardErrorPath = "${logDir}/duckdns.error.log";
    };
  };
}
