inputs@{ pkgs, user, ... }:

{
  programs.opencode = {
    enable = true;
    settings = {
      provider = {
        anthropic = {
          options = {
            baseURL = "https://right.codes/claude-aws/v1";
            # baseURL = "https://api.claudecode.net.cn/api/claudecode";
          };
        };
        openai = {
          options = {
            baseURL = "https://right.codes/gemini/v1";
            # baseURL = "https://api.claudecode.net.cn/api/codex/backend-api/codex";
          };
        };
        google = {
          options = {
            baseURL = "https://right.codes/codex/v1";
            # baseURL = "https://api.claudecode.net.cn/api/gemini";
          };
        };
      };
    };
  };
}
