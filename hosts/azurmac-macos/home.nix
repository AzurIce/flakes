inputs@{
  user,
  pkgs,
  config,
  chat,
  ...
}:

let
  dotfilesPath = "${config.home.homeDirectory}/flakes/.dotfiles";
in
{
  imports = [
    ../../home/programs/git.nix
    ../../home/programs/alacritty.nix
    ../../home/programs/helix.nix
    ../../home/programs/yazi.nix
    ../../home/programs/zellij.nix
    ../../home/programs/zsh.nix
    ../../home/programs/rio.nix
    ../../home/programs/nvim.nix

    ../../home/ai
    ../../home/fonts.nix
    # ../../modules/programs/nvim.nix
    ../../modules/programs/typora/home.nix
    #../../modules/programs/maa/home.nix
    # ../../modules/programs/kitty.nix
    #../../modules/programs/rime.nix
    # ../../modules/programs/obs-studio/home.nix
    # inputs.paneru.homeModules.paneru
  ];

  xdg.configFile."ghostty".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/ghostty";
  # services.paneru = {
  #   enable = true;
  #   # Equivalent to what you would put into `~/.paneru` (See Configuration options below).
  #   settings = {
  #     options = {
  #       preset_column_widths = [
  #         0.25
  #         0.33
  #         0.5
  #         0.66
  #         0.75
  #       ];
  #       swipe_gesture_fingers = 4;
  #       animation_speed = 4000;
  #     };
  #     bindings = {
  #       window_focus_west = "alt - h";
  #       window_focus_east = "alt - l";
  #       window_focus_north = "alt - k";
  #       window_focus_south = "alt - j";
  #       window_swap_west = "alt + shift - h";
  #       window_swap_east = "alt + shift - l";
  #       window_center = "alt - c";
  #       window_resize = "alt - r";
  #       window_fullwidth = "alt - f";
  #       window_manage = "alt + shift - space";
  #       window_stack = "alt - ]";
  #       window_unstack = "alt + shift - ]";
  #     };
  #   };
  # };

  home = {
    username = "${user}";
    homeDirectory = "/Users/${user}";
    packages = with pkgs; [
      btop
      sketchybar
      eza
      inputs.self.packages.${pkgs.system}.cc-switch
      inputs.self.packages.${pkgs.system}.splitrail
    ];
  };

  # home.file.".config/sketchybar".source = ../../home/wm/sketchybar;
  home.file.".barik-config.toml".source = ../../home/wm/.barik-config.toml;

  home.file.".yabairc".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/.yabairc";
  # home.file.".aerospace.toml".source = ./aerospace.toml;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };

  programs.tmux = {
    enable = true;
    mouse = true;
  };
  # programs.ghostty = {
  #   # enable = true;
  #   settings = {
  #     font-family = "JetBrains Mono";
  #     font-size = 16;
  #     background-opacity = 0.8;
  #   };
  # };

  # home.file.".config/ghostty/config".text = ''
  #   font-family = JetBrainsMono Nerd Font
  #   font-size = 16
  #   background-opacity = 0.8
  #   theme = catppuccin-mocha
  #   quit-after-last-window-closed = true
  #   shell-integration-features = ssh-terminfo
  # '';

  # programs.starship = {
  #   enable = true;
  #   # 自定义配置
  #   settings = {
  #     add_newline = false;
  #     # aws.disabled = true;
  #     # gcloud.disabled = true;
  #     # line_break.disabled = true;
  #   };
  # };

  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
}
