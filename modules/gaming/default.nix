{ pkgs, ... }:

{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
  programs.alvr = {
    package = (pkgs.callPackage ../../packages/alvr-nightly.nix { } );
    enable = true;
    openFirewall = true;
  };
}
