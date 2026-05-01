inputs@{ config, pkgs, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/flakes/.dotfiles";

  # Custom luarocks wrapper that includes the rust-mlua build backend.
  # Nix's luarocks hardcodes package.path in .luarocks-wrapped, ignoring LUA_PATH.
  # We patch it to prepend luarocks-build-rust-mlua's path.
  rocksLuarocks = let
    origWrapped = builtins.readFile "${pkgs.lua51Packages.luarocks}/bin/.luarocks-wrapped";
    rustMlua = pkgs.lua51Packages.luarocks-build-rust-mlua;
    modifiedWrapped = pkgs.lib.replaceStrings
      [''package.path="'']
      [''package.path="${rustMlua}/share/lua/5.1/?.lua;${rustMlua}/share/lua/5.1/?/init.lua;'']
      origWrapped;
    wrappedScript = pkgs.writeText "rocks-luarocks-wrapped" modifiedWrapped;
  in pkgs.writeShellScriptBin "rocks-luarocks" ''
    export PATH="${pkgs.gcc}/bin:${pkgs.cargo}/bin:$PATH"
    exec ${pkgs.bash}/bin/sh ${wrappedScript} "$@"
  '';

  luarocksConfigStr = (pkgs.lib.generators.toLua { asBindings = false; } {
    lua_version = "5.1";
    rocks_trees = [
      { name = "rocks.nvim"; root = "${config.home.homeDirectory}/.local/share/nvim/rocks"; }
    ];
    variables = {
      CC = "${pkgs.gcc}/bin/gcc";
    };
  });
in
{
  home.packages = with pkgs; [
    inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.neovim
    lua51Packages.luarocks
    lua51Packages.luarocks-build-rust-mlua
    cargo
    rustc
    gcc
    unzip
    tree-sitter
    rocksLuarocks
  ];

  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/nvim";

  # Nix-generated rocks.nvim auxiliary configs (placed under ~/.local/share/nvim
  # so they travel with the Neovim data dir, and don't pollute dotfiles via symlink)
  xdg.dataFile."nvim/nvim-nix/generated-by-nix.lua".text = ''
    local M = {}
    M.gcc_path = "${pkgs.gcc}/bin/gcc"
    M.luarocks_executable = "${rocksLuarocks}/bin/rocks-luarocks"
    return M
  '';

  xdg.dataFile."nvim/nvim-nix/luarocks-config-generated.lua".text = ''
    return ${luarocksConfigStr}
  '';

  home.shellAliases = {
    vi = "nvim";
    vim = "nvim";
  };
}
