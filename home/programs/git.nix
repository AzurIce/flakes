inputs@{ pkgs, system, mac, ... }:

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
      credential = {
        credentialStore = if mac && system == "aarch64-darwin" then
          "keychain"
        else 
          "secretservice";
        helper = "${pkgs.git-credential-manager}/bin/git-credential-manager";
      };
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
