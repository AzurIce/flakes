inputs@{ config, pkgs, user, ... }:

let
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
  programs.neovim = {
    package = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.neovim;
    enable = true;
    viAlias = true;
    vimAlias = true;
  };

  home.packages = with pkgs; [
    lua51Packages.luarocks
    lua51Packages.luarocks-build-rust-mlua
    cargo
    rustc
    gcc
    unzip
    tree-sitter
    rocksLuarocks
  ];

  xdg.dataFile."nvim/nvim-nix/generated-by-nix.lua".text = ''
    local M = {}
    M.gcc_path = "${pkgs.gcc}/bin/gcc"
    M.luarocks_executable = "${rocksLuarocks}/bin/rocks-luarocks"
    return M
  '';

  xdg.dataFile."nvim/nvim-nix/luarocks-config-generated.lua".text = ''
    return ${luarocksConfigStr}
  '';
}
