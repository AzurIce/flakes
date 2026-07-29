
inputs@{ pkgs, config, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/flakes/.dotfiles";
in
{
  home.packages = [
    inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  xdg.configFile."herdr".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/herdr";
}
