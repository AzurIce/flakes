{ user, nixvim, ... }:

{
  imports = [
    # ../../home/wm/hyprland
    # ../../home/programs/eww
    # ../../home/programs/kitty.nix
    ../../home/programs/nvim.nix

    # ../../modules/programs/typora/home.nix
    ../../home/programs/git.nix
    ../../home/programs/helix.nix
    # ../../home/programs/waybar
  ];

  home = {
    username = "${user}";
    homeDirectory = "/home/${user}";
    stateVersion = "24.11";
  };

  programs.git = {
    enable = true;
    userEmail = "973562770@qq.com";
    userName = "AzurIce";
    extraConfig = {
      # core.excludesFile = "~/.config/git/ignore";
      http.proxy = "http://127.0.0.1:7890";
      https.proxy = "https://127.0.0.1:7890";
      safe.directory = "*";
      credential = {
        credentialStore = "cache";
        helper = "/mnt/c/Program\ Files\ \(x86\)/Git\ Credential\ Manager/git-credential-manager.exe";
      };
    };

    ignores = [
      ".DS_Store"
    ];

    lfs.enable = true;

    delta.enable = true;
  };

  programs.home-manager.enable = true;
  manual.manpages.enable = false;
}
