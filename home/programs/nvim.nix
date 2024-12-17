inputs@{ pkgs, nixvim, ... }:

{
  imports = [
    nixvim.homeManagerModules.nixvim
  ];

  home.packages = with pkgs; [
    nixfmt
  ];

  programs.nixvim = {
    package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.neovim;
    enable = true;
    # defaultEditor = true;

    keymaps = [
      {
        key = "s";
        action = "<nop>";
      }

      # basics
      {
        key = "S";
        action = ":w<CR>";
      }
      {
        key = "Q";
        action = ":q<CR>";
      }

      {
        key = "<C-a>";
        action = "gg<S-v>G";
        mode = "n";
      }
      {
        key = "<C-v>";
        action = "\"+y";
        mode = "v";
      }

      # movements
      {
        key = "J";
        action = "7j";
      }
      {
        key = "K";
        action = "7k";
      }
      {
        key = "H";
        action = "0";
      }
      {
        key = "L";
        action = "$";
      }
    ];
    
    plugins = {
      # Essentials
      web-devicons.enable = true;

      # Tab and buffer management
      bufferline = {
        enable = true;
      };

      lsp = {
        enable = true;
        inlayHints = true;
        servers = {
          lua_ls.enable = true;
          rust_analyzer.enable = true;
        };
      };

      cmp = {
        enable = true;
        autoEnableSources = true;
        settings.sources = [
          { name = "nvim_lsp"; }
          { name = "path"; }
          { name = "buffer"; }
        ];
      };

      # Nix
      nix.enable = true;
      nix-develop.enable = true;
      lsp.servers.nil_ls = {
        enable = true;
        settings = {
          formatting.command = [ "nixfmt" ];
          nix.flake = {
            autoArchive = true;
            autoEvalInputs = true;
          };
        };
      };
    };
  };
}
