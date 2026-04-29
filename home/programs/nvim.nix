inputs@{ config, pkgs, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/flakes/.dotfiles";
in
{
  # Don't use programs.neovim here because it tries to manage ~/.config/nvim,
  # which conflicts with our xdg.configFile."nvim" symlink below.
  home.packages = [
    inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.neovim
  ];

  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/nvim";

  # Manual aliases since we aren't using programs.neovim
  home.shellAliases = {
    vi = "nvim";
    vim = "nvim";
  };
}
