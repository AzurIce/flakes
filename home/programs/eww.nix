{
  config,
  mac,
  ...
}:

let
  dotfilesPath = "${config.home.homeDirectory}/flakes/.dotfiles";
in
{
  programs.eww = {
    enable = true;
  };

  xdg.configFile."eww".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/eww${if mac then "-mac" else ""}";
}
