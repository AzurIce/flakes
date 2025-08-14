{ system, mac, ... }:

{
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    # age.keyFile = "/var/lib/sops-nix/key.txt";
    # 

    age.keyFile = if system == "aarch64-darwin" && mac == true then
        "/Users/azurice/.age-key.txt"
    else
        "/home/azurice/.age-key.txt";

    age.generateKey = true;

    secrets.hashedPassword = {
      # path = "/home/azurice/password";
      neededForUsers = true;
    };
  };
}
