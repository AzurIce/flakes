{
  config,
  mac,
  ...
}:

let
  dotfilesPath = "${config.home.homeDirectory}/flakes/.dotfiles";
in
{
  programs.ashell = {
    enable = true;
  };

  xdg.configFile."ashell".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/ashell${if mac then "-mac" else ""}";
}
