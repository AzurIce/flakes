inputs@{
  system,
  mac,
  ...
}:

{
  nixpkgs.overlays = [
    inputs.claude-code.overlays.default
    (
      final: prev:
      if prev.stdenv.isDarwin then
        {
          # Workaround for zsh sigsuspend autoconf probe failure under C23 on Darwin,
          # which causes $(...) command substitutions to deadlock.
          # See: https://github.com/NixOS/nixpkgs/issues/513543
          zsh = prev.zsh.overrideAttrs (old: {
            preConfigure = (old.preConfigure or "") + ''
              export zsh_cv_sys_sigsuspend=yes
            '';
          });
        }
      else
        { }
    )
  ];

  nix.settings = {
    extra-substituters = [
      "https://mirror.sjtu.edu.cn/nix-channels/store"
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
