inputs@{
  pkgs,
  config,
  user,
  ...
}:

let
  dotfilesPath = "${config.home.homeDirectory}/flakes/.dotfiles";
in
{
  programs.opencode.enable = true;

  xdg.configFile."opencode".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/opencode";
}
