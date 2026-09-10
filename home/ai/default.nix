inputs@{
  config,
  pkgs,
  lib,
  utils,
  ...
}:

let
  gmiCloudKey = config.sops.secrets.gmiCloudKey.path;
  zhipuKey = config.sops.secrets.zhipuKey.path;
  pokeKey = config.sops.secrets.pokeKey.path;
  opencodeGoKey = config.sops.secrets.opencodeGoKey.path;
  minimaxKey = config.sops.secrets.minimaxKey.path;
  deepseekKey = config.sops.secrets.deepseekKey.path;
  zhipuKey = config.sops.secrets.zhipuKey.path;
in
{
  imports = [
    ./splitrail.nix
  ];

  programs.opencode = {
    enable = true;
    package = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.opencode;
  };
  home.packages =
    with pkgs;
    [
      # vibe coding
      # gemini-cli
      antigravity-cli
      claude-code
      codex
      pi-coding-agent

      rtk
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.zcode
    ]
    ++ [
      inputs.cc-statusline.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.kimi-code.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.splitrail
      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.dsh
    ];

  home.file = utils.linkDotfiles [
    ".claude"
    ".codex"
    ".dsh"
    ".kimi-code"
    ".pi"
    ".agents"
  ];
  xdg.configFile = utils.linkDotfiles [
    "openode"
    "rua"
  ];
  xdg.desktopEntries = lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
    zcode = {
      name = "ZCode";
      comment = "ZCode Desktop App";
      exec = "${inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.zcode}/bin/zcode --no-sandbox %U";
      icon = "zcode";
      terminal = false;
      categories = [ "Development" ];
      mimeType = [ "x-scheme-handler/zcode" ];
      settings.StartupWMClass = "ZCode";
    };
  };

  sops.secrets = {
    kimiCodeKey = { };
    zhipuKey = { };
    gmiCloudKey = { };
    pokeKey = { };
    aicodemirrorKey = { };
    minimaxKey = { };
    siliconflowKey = { };
    rightcodeKey = { };
    foxcodeKey = { };
    opencodeGoKey = { };
    zaiKey = { };
    splitrailKey = { };
    deepseekKey = { };
    zhipuKey = { };
  };

  sops.templates."codex-auth.json" = {
    path = "${config.home.homeDirectory}/.codex/auth.json";
    content = builtins.toJSON {
      OPENAI_API_KEY = config.sops.placeholder.pokeKey;
    };
  };

  programs.zsh.initContent = ''
    export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
    export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
    export OPENCODE_ENABLE_EXA=1

    # Other API Keys
    export GMI_CLOUD_API_KEY="$(cat ${gmiCloudKey})"
    export ZAI_CODING_CN_API_KEY="$(cat ${zhipuKey})"
    export POKE_API_KEY="$(cat ${pokeKey})"
    export MINIMAX_API_KEY="$(cat ${minimaxKey})"
    export DEEPSEEK_API_KEY="$(cat ${deepseekKey})"
    export ZHIPUAI_API_KEY="$(cat ${zhipuKey})"
    export OPENCODE_API_KEY="$(cat ${opencodeGoKey})"
    export OPENAI_BASE_URL="https://www.poke2api.com"
    export OPENAI_API_KEY="$(cat ${pokeKey})"
  '';
}
