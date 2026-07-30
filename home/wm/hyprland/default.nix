inputs@{ pkgs, utils, ... }:

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
    # hyprpaper
    wl-clipboard
    # inputs.hyprsession.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.awww.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.clipvault
  ];

  

  xdg.configFile."hypr".source = utils.linkDotfile "hypr";

  programs.zsh.initContent = ''
    switch-wallpaper() {
      "${utils.dotfilesPath}/wallpapaers/switch-wallpaper" "$@"
    }

    alias wp='switch-wallpaper'

    _switch-wallpaper() {
      local -a modes
      modes=(next prev random)
      _describe 'mode' modes
    }
    compdef _switch-wallpaper switch-wallpaper
  '';
}
