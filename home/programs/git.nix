inputs@{ pkgs, lib, system, mac, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      
      user = {
        name = "AzurIce";
        email = "973562770@qq.com";
      };
      http.proxy = "http://127.0.0.1:7890";
      https.proxy = "https://127.0.0.1:7890";
      safe.directory = "*";
      credential.helper = lib.mkIf (!mac)
        "${pkgs.git-credential-manager}/bin/git-credential-manager";
    };

    ignores = [
      ".DS_Store"
    ];

    lfs.enable = true;
  };
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };
}
