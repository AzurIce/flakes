# update a hand-maintained package in packages/ (dsh|cc-switch|clipvault|splitrail|revelo|all)
update pkg *args:
    ./packages/update.sh {{ pkg }} {{ args }}

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
