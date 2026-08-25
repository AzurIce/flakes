
{ pkgs, lib, ... }:

{
  # enable flakes globally
  nix.settings = {
    extra-substituters = [
      # Query the mirror of USTC first, and then the official cache.
      "https://mirrors.ustc.edu.cn/nix-channels/store"
    ];
    trusted-substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
    ];
    experimental-features = [ "nix-command" "flakes" ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # 显式允许 metal-toolchain（exo 带的 Apple 闭源 Metal 编译器）。
  nixpkgs.config.allowUnfreePredicate = pkg: (pkg.pname or "") == "metal-toolchain";

  # Auto upgrade nix package and the daemon service.
  # services.nix-daemon.enable = true;

  # nix.package = pkgs.nix;
  nix.package = pkgs.nixVersions.latest;
  programs.nix-index.enable = true;

  nix.gc = {
    automatic = lib.mkDefault true;
    options = lib.mkDefault "--delete-older-than 7d";
  };

  nix.settings = {
    auto-optimise-store = false;
  };
}
