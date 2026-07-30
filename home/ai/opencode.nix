inputs@{
  pkgs,
  user,
  utils,
  ...
}:

{
  programs.opencode.enable = true;

  xdg.configFile."opencode".source = utils.linkDotfile "opencode";
}
