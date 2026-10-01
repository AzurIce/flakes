inputs@{ user, config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    dotDir = config.home.homeDirectory;
    initContent= ''
      # export TERM=xterm-256color
      export PATH=$PATH:$HOME/.cargo/bin
      export PATH=$PATH:$HOME/.local/bin

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

  home.packages = with pkgs; [
    eza
  ];
}

