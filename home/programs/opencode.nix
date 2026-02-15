inputs@{ pkgs, user, ... }:

{
  programs.opencode = {
    enable = true;
    settings = {
      provider = {
        anthropic = {
          options = {
            baseURL = "https://api.claudecode.net.cn/api/claudecode";
          };
        };
        openai = {
          options = {
            baseURL = "https://api.claudecode.net.cn/api/codex/backend-api/codex";
          };
        };
        google = {
          options = {
            baseURL = "https://api.claudecode.net.cn/api/gemini";
          };
        };
      };
    };
  };
}
