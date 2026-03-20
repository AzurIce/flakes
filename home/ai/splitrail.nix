{
  config,
  pkgs,
  ...
}:

{
  # Has problem with last_upload_timestamp, so managed manually for now
  # sops = {
  #   age.keyFile = "/Users/azurice/.age-key.txt";
  #   defaultSopsFile = ../../secrets/secrets.yaml;
  #   secrets.splitrailKey = { };
  #   templates."splitrail.toml".content = ''
  #     [server]
  #     url = "https://splitrail.dev"
  #     api_token = "${config.sops.placeholder.splitrailKey}"

  #     [upload]
  #     auto_upload = false
  #     upload_today_only = false

  #     [formatting]
  #     number_comma = false
  #     number_human = false
  #     locale = "en"
  #     decimal_places = 2
  #   '';
  # };
  # home.file.".splitrail.toml".source = config.lib.file.mkOutOfStoreSymlink config.sops.templates."splitrail.toml".path;
}
