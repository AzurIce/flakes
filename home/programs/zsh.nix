inputs@{ user, config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    initContent= ''
      export PATH=$PATH:/Users/azurice/.cargo/bin

      alias ls="eza"
      alias ll="eza -l"
      alias la="eza -a"
      alias lla="eza -la"
    '';
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [
        "git"
        "ag"
        "aliases"
        # "colored-man-page"
        "colorize"
        "copypath"
        "direnv"
        # "zsh-autosuggestions"
      ];
    };
  };
}

