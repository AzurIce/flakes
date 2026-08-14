# Override Obsidian to the latest 1.13.7 release.
#
# NOTE: nixos-unstable (as of 2026-08-13) still ships Obsidian 1.13.4.
# The bump to 1.13.7 is pending upstream in
#   NixOS/nixpkgs#551212  "obsidian: 1.13.4 -> 1.13.7"
# (https://github.com/NixOS/nixpkgs/pull/551212)
#
# Once that PR is merged and lands in nixos-unstable, this overlay becomes a
# no-op and can be deleted.

{
  nixpkgs.overlays = [
    (
      final: prev:
      let
        # Keep in sync with NixOS/nixpkgs#551212
        obsidianVersion = "1.13.7";
        # x86_64-linux fetch for 1.13.7:
        src = final.fetchurl {
          url = "https://github.com/obsidianmd/obsidian-releases/releases/download/v${obsidianVersion}/obsidian-${obsidianVersion}.tar.gz";
          hash = "sha256-08vjdcv6QCTbGRC5gZFkn0E0xcSK7l5gtudxOYfc2yg=";
        };
      in
      {
        obsidian = prev.obsidian.overrideAttrs (old: {
          version = obsidianVersion;
          inherit src;
        });
      }
    )
  ];
}
