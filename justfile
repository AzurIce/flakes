# check & update hand-maintained packages in packages/ (FILTER: optional regex, e.g. '^splitrail')
update *filter:
    # keyfile rendered by sops-nix from the githubToken secret (see
    # home/default.nix); ~/.config/nvchecker/keyfile.toml as manual fallback
    KF="$HOME/.config/sops-nix/secrets/rendered/nvchecker-keyfile.toml"; [ -f "$KF" ] || KF="$HOME/.config/nvchecker/keyfile.toml"; nvfetcher -c packages/nvfetcher.toml -o packages/_sources $(test -f "$KF" && echo --keyfile "$KF") {{ filter }}

# regenerate dsh's vendored package-lock.json + npmDepsHash (run after `just update` bumps dsh)
update-dsh:
    ./packages/update-dsh.sh

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
