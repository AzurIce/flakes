rebuild target=".#":
    sudo nixos-rebuild switch --flake {{target}}
      
# build and switch for mac
darwin target=".#":
  darwin-rebuild switch --flake {{target}}
  just proxy

# set proxy for mac
proxy:
  sudo python3 hosts/azurmac-macos/scripts/darwin_set_proxy.py
