inputs@{ user, pkgs, ... }:

let
  # llama.cpp CUDA 后端构建（只编 sm_89，见 configuration.nix 的 cudaCapabilities）
  llama-cpp-cuda = pkgs.llama-cpp.override { cudaSupport = true; };
  # hf CLI：python env 直接放进 home.packages 会触发新版 module system 的
  # package 类型检查误报（types.nix listOf v2 求值路径），symlinkJoin 包装后正常
  hf-cli = pkgs.symlinkJoin {
    name = "hf-cli";
    paths = [ (pkgs.python3.withPackages (ps: [ ps."huggingface-hub" ])) ];
  };
in

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

      mold
      zed-editor
      obsidian

      godot_4
      blender
      chromium
      mpv
      gh

      inputs.notist.packages.${pkgs.stdenv.hostPlatform.system}.default

      # 本地推理：llama.cpp（CUDA）+ hf 模型下载 + 起服务包装器
      llama-cpp-cuda
      hf-cli
      (writeShellScriptBin "llama-serve" ''
        # llama-server：OpenAI 兼容 API(http://127.0.0.1:8010/v1) + 内置 WebUI(/)
        # 参数原样透传给 llama-server，例如：
        #   llama-serve -m ~/models/Qwen3-30B-A3B-UD-Q3_K_XL.gguf
        # 下载模型（建议 --local-dir 存到 ~/models）：
        #   hf download unsloth/Qwen3-30B-A3B-Instruct-2507-GGUF --local-dir ~/models
        exec ${llama-cpp-cuda}/bin/llama-server \
          --n-gpu-layers 99 \
          --ctx-size 32768 \
          --flash-attn on \
          --jinja \
          --host 127.0.0.1 \
          --port 8010 \
          "$@"
      '')
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
