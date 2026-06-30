inputs@{ pkgs, user, config, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/flakes/.dotfiles";
in
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
    source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/fcitx5";
  };
}
