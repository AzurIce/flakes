{
  mac,
  utils,
  ...
}:

{
  programs.ashell = {
    enable = true;
  };

  xdg.configFile."ashell".source = utils.linkDotfile "ashell${if mac then "-mac" else ""}";
}
