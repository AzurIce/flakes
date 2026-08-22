inputs@{ pkgs, utils, ... }:

{
  imports = [
    inputs.hyprcursor-phinger.homeManagerModules.hyprcursor-phinger
  ];

  programs.hyprcursor-phinger.enable = true;

  xdg = {
    enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "vivaldi-stable.desktop";
        "x-scheme-handler/http" = "vivaldi-stable.desktop";
        "x-scheme-handler/https" = "vivaldi-stable.desktop";
        "x-scheme-handler/about" = "vivaldi-stable.desktop";
        "x-scheme-handler/unknown" = "vivaldi-stable.desktop";
      };
    };
  };

  home.sessionVariables.BROWSER = "vivaldi";

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

    satty
    kitty
    rofi
    wlogout
    # hyprpaper
    wl-clipboard
    # inputs.hyprsession.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.awww.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.wayshot.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.clipvault
    # 桌面 shell（bar/launcher/通知/控制中心），替代 ashell
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default

    # 亮度控制：brightnessctl（笔记本/内屏）+ ddcutil（外接显示器）
    brightnessctl
    ddcutil
  ];

  xdg.configFile = utils.linkDotfiles [
    "wayshot"
    "hypr"
    "satty"
    "noctalia"
  ];

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
