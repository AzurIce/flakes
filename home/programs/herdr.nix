
inputs@{ pkgs, utils, ... }:

{
  home.packages = [
    inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  xdg.configFile."herdr".source = utils.linkDotfile "herdr";
}
