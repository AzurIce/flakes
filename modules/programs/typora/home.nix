inputs@{ pkgs, user, system, mac, ... }:

{
  imports =
    if system == "aarch64-darwin" && mac == true then
        [ ./home-darwin.nix ]
    else
        [];
}
