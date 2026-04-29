inputs@{ pkgs, nixvim, ... }:

{
  imports = [
    nixvim.homeModules.nixvim
  ];

  home.packages = with pkgs; [
    nixfmt
  ];

  programs.nixvim = {
    package = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.neovim;
    enable = true;
    # defaultEditor = true;

    colorscheme = "ayu";
    colorschemes.ayu = {
      enable = true;
      settings.mirage = true;
    };

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

      {
        key = "<C-Esc>";
        action = "<C-\\><C-n>";
        mode = "t";
      }
    ];
    
    plugins = {
      # Essentials
      web-devicons.enable = true;

      # Tab and buffer management
      bufferline.enable = true;
      airline.enable = true;
      alpha = {
        enable = true;
        theme = "dashboard";
      };

      neo-tree = {
        enable = true;
        settings = {
          add_blank_line_at_top= true;
          sources = [ "filesystem" "buffers" "git_status" "document_symbols" ];
          filesystem = {
            bind_to_cwd= false;
            follow_current_file.enabled = true;
            use_libuv_file_watcher = true;
          };
          source_selector = {
            winbar = true;
            statusline = false;
          };
          window = {
            mappings = {
              "<space>" = "none";
              "<cr>" = {
                command = "toggle_node";
                config = { nowait = true; };
              };
              "o" = "open";
            };
          };
        };
      };

      toggleterm = {
        enable = true;
      };

      treesitter = {
        enable = true;

        grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          json
          lua
          markdown
          nix
          toml
          rust
          yaml
        ];
        # folding = true;
        settings = {
          highlight.enable = true;
          incremental_selection.enable = true;
          indent.enable = true;
        };
      };
      lsp = {
        enable = true;
        inlayHints = true;
        keymaps = {
          lspBuf = {
            gD = "declaration";
            gd = "definition";
            gi = "implementation";
            gr = "references";
            "<space>i" = "hover";
            "<space>D" = "type_definition";
            "<space>r" = "rename";
            "<space>f" = "format";
            "<space>a" = "code_action";
          };
        };
        servers = {
          lua_ls.enable = true;
        };
      };

      cmp = {
        enable = true;
        autoEnableSources = true;
        settings = {
          sources = [
            { name = "nvim_lsp"; }
            { name = "path"; }
            { name = "buffer"; }
            { name = "crates"; }
          ];
          mapping = {
            "<C-j>" = "cmp.mapping.scroll_docs(-4)";
            "<C-k>" = "cmp.mapping.scroll_docs(4)";
            "<C-e>" = "cmp.mapping.close()";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
            "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
          };
        };
      };

      # Rust
      lsp.servers.rust_analyzer = {
        enable = true;
        installCargo = false;
        installRustc = false;
      };
      crates = {
        enable = true;
        settings.lsp = {
          enabled = true;
          actions = true;
          completion = true;
          hover = true;
        };
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
