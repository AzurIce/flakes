# 保留 comfyui-nix 的 CUDA 包装与依赖，只更新本机需要的核心及配套版本。
# H3-Image 等模型需要更新后的核心及配套前端。
{
  upstream,
  system ? "x86_64-linux",
}:
assert system == "x86_64-linux";
let
  pkgs = import upstream.inputs.nixpkgs {
    inherit system;
    config = {
      allowUnfree = true;
      allowBrokenPredicate = pkg: (pkg.pname or "") == "open-clip-torch";
    };
  };
  versions = import ./comfyui-versions.nix {
    base = import "${upstream}/nix/versions.nix";
  };
  gpuSupport = "cuda";
  pythonOverrides = import "${upstream}/nix/python-overrides.nix" {
    inherit pkgs versions gpuSupport;
  };
in
(import "${upstream}/nix/packages.nix" {
  inherit
    pkgs
    versions
    gpuSupport
    pythonOverrides
    ;
  lib = pkgs.lib;
}).default
