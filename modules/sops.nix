{ sops-nix, ... }:

{
  imports = [
    sops-nix.nixosModules.sops
  ];
  # In .sops.yaml are the age public keys used to decrypt the secrets.
  #
  # An age key can be generated with:
  # `age-keygen -o ~/.config/sops/age/keys.txt`
  # or be converted from ssh key with:
  # nix-shell -p ssh-to-age --run "ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt"
  #
  # Machine's ssh is in `/etc/ssh/` (or in our case, `/persist/etc/ssh/`), these two should be identical:
  # `nix-shell -p ssh-to-age --run 'ssh-keyscan example.com | ssh-to-age'`
  # `nix-shell -p ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'`
  #
  # New machine setup:
  # 1. get age public key from machine's ssh and add into `.sops.yaml` then do updatekeys
  # 2. generate a user's age key to `~/.config/sops/age/keys.txt` and add into `.sops.yaml` then do updatekeys
  sops = {
    defaultSopsFile = ../secrets/system.yaml;
    age = {
      sshKeyPaths = [
        "/etc/ssh/ssh_host_ed25519_key"
        "/persist/etc/ssh/ssh_host_ed25519_key"
      ];
    };

    secrets = {
      hashedPassword = {
        neededForUsers = true;
      };
    };
  };
}
