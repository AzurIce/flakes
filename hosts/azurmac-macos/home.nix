inputs@{
  user,
  pkgs,
  config,
  chat,
  ...
}:

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
    ../../home/programs/opencode.nix

    ../../modules/fonts.nix
    # ../../modules/programs/nvim.nix
    ../../modules/programs/typora/home.nix
    #../../modules/programs/maa/home.nix
    # ../../modules/programs/kitty.nix
    #../../modules/programs/rime.nix
    # ../../modules/programs/obs-studio/home.nix
    # inputs.paneru.homeModules.paneru
  ];

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

  home.file.".yabairc".text = ''
    # yabai -m config focus_follows_mouse autofocus

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
    yabai -m rule --add app="^Clash.*$" manage=off
    yabai -m rule --add app="^访达$" manage=off
    yabai -m rule --add app="^GitHub Desktop$" manage=off
    yabai -m rule --add app="^微信$" manage=off
    yabai -m rule --add app="^QQ$" manage=off
    yabai -m rule --add app="^网易云音乐$" manage=off
    yabai -m rule --add app="^系统设置$" manage=off
    yabai -m rule --add app="^磁盘工具$" manage=off
    yabai -m rule --add app="^evt-app$" manage=off
    yabai -m rule --add app="^evt-.*$" manage=off
    yabai -m rule --add app="^winit window$" manage=off
    yabai -m rule --add app="^Epic Games.*$" manage=off
    yabai -m rule --add title="^虚幻项目浏览器$" manage=off
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
    quit-after-last-window-closed = true
    shell-integration-features = ssh-terminfo
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
