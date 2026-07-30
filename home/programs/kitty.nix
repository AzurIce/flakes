inputs@{ pkgs, utils, ... }:

{
  home.packages = [ pkgs.kitty ];

  xdg.configFile."kitty".source = utils.linkDotfile "kitty";
}
