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
    enable = true;
    name = "phinger-cursors-dark";
    package = pkgs.phinger-cursors;
    size = 24;
    gtk.enable = true;
  };

  home.packages = with pkgs; [
    jq
    socat

    kitty
    rofi
    wlogout
    hyprpaper
    wl-clipboard
    # inputs.hyprsession.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.clipvault
  ];

  xdg.configFile."hypr".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/hypr";
}
