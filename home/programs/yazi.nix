{ pkgs, utils, ... }:

{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";
  };

  # yazi 解压快捷键（keymap.toml 里的 x）依赖 ouch
  home.packages = [ pkgs.ouch ];

  xdg.configFile."yazi".source = utils.linkDotfile "yazi";
}
