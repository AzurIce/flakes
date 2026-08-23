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
    ../../home/programs/webapp.nix
    # ../../home/programs/nvim.nix

    ../../modules/programs/typora/home.nix
    ../../home/programs/git.nix
    ../../home/programs/helix.nix
    # ../../home/programs/nvim.nix
  ];

  home = {
    username = "${user}";
    homeDirectory = "/home/${user}";
    stateVersion = "24.11";
    packages = with pkgs; [
      # QQ 在 Hyprland + fcitx5 下 --wayland-text-input-version=3 注册不上输入法；
      # drun 从 systemd 会话启动时还可能缺少 GTK_IM_MODULE，统一在包装器中补齐。
      (symlinkJoin {
        name = "qq-imefix";
        paths = [ qq ];
        nativeBuildInputs = [ makeWrapper ];
        postBuild = ''
          rm $out/bin/qq
          makeWrapper ${qq}/bin/qq $out/bin/qq \
            --set GTK_IM_MODULE fcitx \
            --set QT_IM_MODULE fcitx \
            --set SDL_IM_MODULE fcitx \
            --set XMODIFIERS "@im=fcitx" \
            --set NIXOS_OZONE_WL "" \
            --add-flags "--ozone-platform=wayland" \
            --add-flags "--enable-features=WaylandWindowDecorations" \
            --add-flags "--enable-wayland-ime=true" \
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
      mpv
      gh

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
