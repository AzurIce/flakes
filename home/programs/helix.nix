inputs@{ pkgs, system, mac, ... }:

{
  programs.helix = {
    enable = true;
    defaultEditor = true;
    # extraPackages = with pkgs; [ rust-analyazer ];

    languages = {
      language = [
        { name = "rust"; }
        { name = "nix"; formatter.command = "nixpkgs-fmt"; }
      ];
    };

    settings = {
      editor = {
        statusline = {
          left = [ "mode" "spinner" "file-name" "read-only-indicator" "file-modification-indicator" ];
          right = [ "diagnostics" "selections" "register" "position" "file-encoding" ];
        };
        lsp = {
          display-messages = true;
          display-inlay-hints = true;
        };
      };
    };
  };
}
