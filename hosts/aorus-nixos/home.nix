inputs@{ user, pkgs, ... }:

{
  imports = [
    ../../home
    ../../home/fonts.nix
    ../../home/programs/zsh.nix
    ../../home/ai
    ../../home/wm/hyprland
    ../../home/programs/kitty.nix
    ../../home/programs/yazi.nix
    ../../home/programs/fcitx5.nix
    ../../home/programs/herdr.nix
    # ../../home/programs/nvim.nix

    ../../modules/programs/typora/home.nix
    ../../home/programs/git.nix
    ../../home/programs/helix.nix
    ../../home/programs/waybar
  ];

  home = {
    username = "${user}";
    homeDirectory = "/home/${user}";
    stateVersion = "24.11";
    packages = with pkgs; [
      # QQ 在 Hyprland + fcitx5 下 --wayland-text-input-version=3 注册不上输入法,
      # 覆盖成 v1(命令行和 .desktop 图标都走包装后的 bin)。
      (symlinkJoin {
        name = "qq-imefix";
        paths = [ qq ];
        nativeBuildInputs = [ makeWrapper ];
        postBuild = ''
          rm $out/bin/qq
          makeWrapper ${qq}/bin/qq $out/bin/qq \
            --add-flags "--wayland-text-input-version=1"
          rm -f $out/share/applications/qq.desktop
          substitute ${qq}/share/applications/qq.desktop \
            $out/share/applications/qq.desktop \
            --replace-fail "${qq}/bin/qq" "$out/bin/qq"
        '';
      })
      wechat
      wemeet

      zed-editor
      obsidian

      godot_4
      blender
      chromium

      inputs.notist.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };

  programs = {
    direnv = {
      enable = true;
      enableBashIntegration = true; # see note on other shells below
      nix-direnv.enable = true;
    };

    bash.enable = true; # see note on other shells below
  };

  programs.zed-editor.enable = true;

  programs.home-manager.enable = true;
  manual.manpages.enable = false;
}
