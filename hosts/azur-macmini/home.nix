inputs@{
  user,
  config,
  pkgs,
  ...
}:

{
  imports = [
    ../../home/programs/git.nix
    ../../home/programs/alacritty.nix
    ../../home/programs/helix.nix
    ../../home/programs/zellij.nix
    ../../home/programs/zsh.nix
    ../../home/programs/rio.nix
    ../../home/programs/opencode.nix
    ../../home/programs/splitrail.nix

    ../../modules/fonts.nix
    ../../modules/programs/nvim.nix
    ../../modules/programs/typora/home.nix
    #../../modules/programs/maa/home.nix
    ../../modules/programs/kitty.nix
    #../../modules/programs/rime.nix
    # ../../modules/programs/obs-studio/home.nix
  ];

  home = {
    username = "${user}";
    homeDirectory = "/Users/${user}";
    packages = with pkgs; [
      btop
      inputs.self.packages.${pkgs.system}.cc-switch
      inputs.self.packages.${pkgs.system}.splitrail
    ];
  };

  # home.file.".yabairc".text = ''
  #   # layout
  #   yabai -m config layout bsp

  #   # paddings and gaps
  #   yabai -m config top_padding    4
  #   yabai -m config bottom_padding 4
  #   yabai -m config left_padding   4
  #   yabai -m config right_padding  4
  #   yabai -m config window_gap     8

  #   # rules
  #   yabai -m rule --add app="^Karabiner-Elements$" manage=off
  #   yabai -m rule --add app="^Clash Nyanpasu$" manage=off
  #   yabai -m rule --add app="^访达$" manage=off
  #   yabai -m rule --add app="^GitHub Desktop$" manage=off
  #   yabai -m rule --add app="^微信$" manage=off
  #   yabai -m rule --add app="^网易云音乐$" manage=off
  #   yabai -m rule --add app="^系统设置$" manage=off
  #   yabai -m rule --add app="^evt-app$" manage=off
  # '';
  # home.file.".aerospace.toml".source = ./aerospace.toml;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };

  programs.aria2 = {
    enable = true;
    settings = {
      enable-rpc = true;
      rpc-listen-port = 6800;
      bt-tracker = "udp://tracker.opentrackr.org:1337/announce,udp://open.demonii.com:1337/announce,http://open.tracker.cl:1337/announce,udp://open.stealth.si:80/announce,udp://explodie.org:6969/announce,udp://tracker.torrent.eu.org:451/announce,udp://tracker.ololosh.space:6969/announce,udp://isk.richardsw.club:6969/announce,udp://exodus.desync.com:6969/announce,http://www.torrentsnipe.info:2701/announce,http://tracker.xiaoduola.xyz:6969/announce,http://tracker.sbsub.com:2710/announce,http://tracker.moxing.party:6969/announce,http://tracker.lintk.me:2710/announce,http://tracker.ipv6tracker.org:80/announce,http://tracker.dmcomic.org:2710/announce,http://shubt.net:2710/announce,http://servandroidkino.ru:80/announce,http://seeders-paradise.org:80/announce,http://home.yxgz.club:6969/announce";
    };
  };

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
