{ user, ... }:

{
  imports = [
    ../../home/programs/git.nix
    ../../home/programs/helix.nix
  ];

  home = {
    username = "${user}";
    homeDirectory = "/home/${user}";
    stateVersion = "24.05";
  };

  programs.home-manager.enable = true;
  manual.manpages.enable = false;
}
