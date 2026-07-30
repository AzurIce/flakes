{ config, lib, ... }:
let
  dotfilesPath = "${config.home.homeDirectory}/flakes/.dotfiles";
in
{
  _module.args.utils = {
    inherit dotfilesPath;

    linkDotfile = rel: config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/${rel}";

    linkDotfiles =
      names:
      lib.genAttrs names (name: {
        source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/${name}";
      });
  };
}
