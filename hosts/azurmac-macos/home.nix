inputs@{ user, pkgs, config, chat, ... }:

{
  imports = [
    ../../home/programs/git.nix
    ../../home/programs/alacritty.nix
    ../../home/programs/helix.nix
    ../../home/programs/yazi.nix
    ../../home/programs/zellij.nix
    ../../home/programs/zsh.nix
    ../../home/programs/rio.nix

    ../../modules/fonts.nix
    ../../modules/programs/nvim.nix
    ../../modules/programs/typora/home.nix
    #../../modules/programs/maa/home.nix
    # ../../modules/programs/kitty.nix
    #../../modules/programs/rime.nix
    # ../../modules/programs/obs-studio/home.nix
  ];

  home = {
    username = "${user}";
    homeDirectory = "/Users/${user}";
    packages = with pkgs; [
      btop
      sketchybar
      eza
    ];
  };

  # home.file.".config/sketchybar".source = ../../home/wm/sketchybar;
  home.file.".barik-config.toml".source = ../../home/wm/.barik-config.toml;

  home.file.".yabairc".text = ''
    yabai -m config focus_follows_mouse autofocus

    yabai -m config mouse_modifier alt
    yabai -m config mouse_action1 move
    yabai -m config mouse_action2 resize

    # layout
    yabai -m config layout bsp

    # visuals
    yabai -m config window_opacity on
    yabai -m config active_window_opacity 1.0
    yabai -m config normal_window_opacity 0.9

    # paddings and gaps
    yabai -m config top_padding    8
    yabai -m config bottom_padding 4
    yabai -m config left_padding   4
    yabai -m config right_padding  4
    yabai -m config window_gap     8

    # rules
    yabai -m rule --add app="^Karabiner-Elements$" manage=off
    yabai -m rule --add app="^Clash Nyanpasu$" manage=off
    yabai -m rule --add app="^访达$" manage=off
    yabai -m rule --add app="^GitHub Desktop$" manage=off
    yabai -m rule --add app="^微信$" manage=off
    yabai -m rule --add app="^QQ$" manage=off
    yabai -m rule --add app="^网易云音乐$" manage=off
    yabai -m rule --add app="^系统设置$" manage=off
    yabai -m rule --add app="^evt-app$" manage=off
    yabai -m rule --add app="^winit window$" manage=off
  '';
  # home.file.".aerospace.toml".source = ./aerospace.toml;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };

  # programs.ghostty = {
  #   # enable = true;
  #   settings = {
  #     font-family = "JetBrains Mono";
  #     font-size = 16;
  #     background-opacity = 0.8;
  #   };
  # };

  home.file.".config/ghostty/config".text = ''
    font-family = JetBrainsMono Nerd Font
    font-size = 16
    background-opacity = 0.8
    theme = catppuccin-mocha
  '';

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
