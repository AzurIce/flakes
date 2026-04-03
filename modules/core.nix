inputs@{
  system,
  mac,
  ...
}:

{
  nixpkgs.overlays = [ inputs.claude-code.overlays.default ];

  nix.settings = {
    substituters = [
      "https://nix-community.cachix.org"
    ];

    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    age = {
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

      # New machine setup:
      # 1. age-keygen -o ~/.age-key.txt
      # 2. Add public key to .sops.yaml recipients
      # 3. sops updatekeys secrets/secrets.yaml
      keyFile =
        if system == "aarch64-darwin" && mac == true then
          "/Users/azurice/.age-key.txt"
        else
          "/home/azurice/.age-key.txt";
    };

    secrets = {
      hashedPassword = {
        neededForUsers = true;
      };
    };
  };
}
