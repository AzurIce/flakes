
inputs@{ pkgs, config, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/flakes/.dotfiles";
in
{
  home.packages = [
    inputs.herder.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  xdg.configFile."herder".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/herder";
}
