{ config, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/flakes/.dotfiles";
in
{
  programs.zed-editor.enable = true;

  xdg.configFile."zed".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/zed";
}
