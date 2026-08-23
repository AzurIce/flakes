{ config, ... }:
{
  imports = [ ./utils.nix ];

  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    age = {
      keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    };

    secrets = {
      # access-tokens = github.com=xxxxxx
      access-tokens = { };
    };
  };

  programs.ssh = {
    enable = true;
    settings = {
       lab = {
         hostname = "58.87.79.189";
         user = "user";
         port = 32222;
       };
     };
  };
   

  # https://github.com/NixOS/nix/issues/6536#issuecomment-1254858889
  nix.extraOptions = ''
    !include ${config.sops.secrets."access-tokens".path}
  '';
}
