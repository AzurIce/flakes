{ utils, ... }:

{
  programs.zed-editor.enable = true;

  xdg.configFile."zed".source = utils.linkDotfile "zed";
}
