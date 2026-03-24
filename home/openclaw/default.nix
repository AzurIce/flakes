{ config, ... }:

{
  sops.secrets.openclawTelegramToken = { };

  programs.openclaw = {
    enable = true;
    instances.default = {
      enable = true;
      appDefaults.nixMode = true;
      config = {
        gateway = {
          mode = "local";
          auth.token = "nix-openclaw-gateway-auth-token-change-me-if-needed";
        };
        channels.telegram = {
          tokenFile = config.sops.secrets.openclawTelegramToken.path;
          allowFrom = [ 7241214842 ];
        };
      };
    };
  };
}
