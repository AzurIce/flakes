# check & update hand-maintained packages in packages/ (FILTER: optional regex, e.g. '^splitrail')
update filter="":
    # keyfile rendered by sops-nix from the githubToken secret (see
    # home/default.nix); ~/.config/nvchecker/keyfile.toml as manual fallback
    KF="$HOME/.config/sops-nix/secrets/rendered/nvchecker-keyfile.toml"; [ -f "$KF" ] || KF="$HOME/.config/nvchecker/keyfile.toml"; nvfetcher -c packages/nvfetcher.toml -o packages/_sources $(test -f "$KF" && echo --keyfile "$KF") {{ if filter == "" { "" } else { "-f '" + filter + "'" } }}

# 丢弃 nvfetcher 的 prefetch 缓存后重拉（哈希与上游不符时用；见 nvfetcher.toml 顶部）
update-refetch:
    nvfetcher -c packages/nvfetcher.toml -o packages/_sources purge
    just update

# 一键更新：flake inputs → nvfetcher 源 → dsh/rea 的 npm 依赖锁
update-all: update-inputs update update-deps

update-inputs:
    nix flake update

# dsh/rea 的 lock 与 npmDepsHash 只在版本变化时重算（脚本内自行判断）
update-deps: update-dsh update-rea

# regenerate dsh's vendored package-lock.json + npmDepsHash (run after `just update` bumps dsh)
update-dsh:
    ./packages/update-dsh.sh

# regenerate REA's vendored package-lock.json + npmDepsHash after `just update` bumps REA
update-rea:
    ./packages/update-rea.sh

# ZCode 不在 nvfetcher 里：抓最新版本、校验 sha512 后改写 packages/zcode.nix
update-zcode:
    ./packages/update-zcode.sh

# 用 nixfmt 格式化全部 .nix（含未跟踪文件）
fmt:
    nix fmt

fmt-check:
    NIX_FMT_CHECK=1 nix fmt

rebuild target=".#":
    sudo nixos-rebuild switch --flake {{ target }}

# build and switch for mac
darwin target=".#":
    nh darwin switch {{ target }}
    # sudo darwin-rebuild switch --flake {{ target }}
    just proxy

# set proxy for mac
proxy:
    sudo python3 hosts/azurmac-macos/scripts/darwin_set_proxy.py
