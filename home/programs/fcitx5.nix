inputs@{ pkgs, user, utils, ... }:

{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        fcitx5-rime
      ];
    };
  };

  xdg.configFile."fcitx5" = {
    recursive = true;
    source = utils.linkDotfile "fcitx5";
  };

  xdg.dataFile."fcitx5/rime" = {
    recursive = true;
    source = utils.linkDotfile "rime";
  };
}
