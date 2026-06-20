inputs@{ pkgs, config, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/flakes/.dotfiles";
in
{
  imports = [
    inputs.hyprcursor-phinger.homeManagerModules.hyprcursor-phinger
  ];

  programs.hyprcursor-phinger.enable = true;
  home.pointerCursor = {
    name = "phinger-cursors-dark";
    package = pkgs.phinger-cursors;
    size = 24;
    gtk.enable = true;
  };

  home.packages = with pkgs; [
    eww
    jq
    socat

    kitty
    rofi
    wlogout
    hyprpaper
  ];

  xdg.configFile."hypr".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/hypr";
}
