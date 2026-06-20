{ config, ... }:
{
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    age = {
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      keyFile = "${config.home.homeDirectory}/.age-key.txt";
    };
    secrets = {
      access-tokens = { };
    };
  };

  # https://github.com/NixOS/nix/issues/6536#issuecomment-1254858889
  nix.extraOptions = ''
    !include ${config.sops.secrets."access-tokens".path}
  '';
}
