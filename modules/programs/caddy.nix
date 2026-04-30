{ config, pkgs, ... }:

{
  home.packages = [ pkgs.caddy ];

  xdg.configFile."caddy/Caddyfile".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/caddy/Caddyfile";

  launchd.agents.caddy = {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.caddy}/bin/caddy"
        "run"
        "--config"
        "${config.xdg.configHome}/caddy/Caddyfile"
        "--adapter"
        "caddyfile"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "${config.xdg.dataHome}/caddy/logs/caddy.log";
      StandardErrorPath = "${config.xdg.dataHome}/caddy/logs/caddy.error.log";
    };
  };
}
