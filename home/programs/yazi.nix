inputs@{ pkgs, system, mac, ... }:

{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";
  };
}
