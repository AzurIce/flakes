{
  system,
  mac,
  config,
  ...
}:

{
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    # age.keyFile = "/var/lib/sops-nix/key.txt";

    age.keyFile =
      if system == "aarch64-darwin" && mac == true then
        "/Users/azurice/.age-key.txt"
      else
        "/home/azurice/.age-key.txt";

    age.generateKey = true;

    secrets = {
      hashedPassword = {
        # path = "/home/azurice/password";
        neededForUsers = true;
      };
      aicodemirrorKey = {
        owner = "azurice";
      };
      minimaxKey = {
        owner = "azurice";
      };
      siliconflowKey = {
        owner = "azurice";
      };
      rightcodeKey = {
        owner = "azurice";
      };
      splitrailKey = {
        owner = "azurice";
      };
    };
  };

  programs.zsh.shellInit = ''
    export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
    # export ANTHROPIC_BASE_URL="https://right.codes/claude-aws"
    export ANTHROPIC_BASE_URL="https://right.codes/claude"
    export ANTHROPIC_AUTH_TOKEN="$(cat ${config.sops.secrets.rightcodeKey.path})"
    # export ANTHROPIC_BASE_URL="https://api.claudecode.net.cn/api/claudecode"
    # export ANTHROPIC_BASE_URL="https://api.aicodemirror.com/api/claudecode"
    # export ANTHROPIC_AUTH_TOKEN="$(cat ${config.sops.secrets.aicodemirrorKey.path})"
    export GOOGLE_GEMINI_BASE_URL="https://api.aicodemirror.com/api/gemini"
    # export GOOGLE_GEMINI_BASE_URL="https://api.claudecode.net.cn/api/gemini"
    # export OPENAI_BASE_URL="https://api.claudecode.net.cn/api/codex/backend-api/codex"
    export OPENAI_API_KEY="$(cat ${config.sops.secrets.aicodemirrorKey.path})"
    export GEMINI_API_KEY="$(cat ${config.sops.secrets.aicodemirrorKey.path})"
    export MINIMAX_API_KEY="$(cat ${config.sops.secrets.minimaxKey.path})"
  '';
}
