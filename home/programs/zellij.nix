inputs@{ pkgs, system, mac, ... }:

{
  programs.zellij = {
    enable = true;
    # enableZshIntegration = true;
    # attachExistingSession = true;
  };
}
