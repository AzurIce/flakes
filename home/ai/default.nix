inputs@{
  config,
  pkgs,
  lib,
  utils,
  osConfig,
  ...
}:

let
  secret = name: config.sops.secrets.${name}.path;

  # 环境变量名 <- sops secret 名
  keys = {
    POKE_API_KEY = "pokeKey";
    STEP_FUN_API_KEY = "stepKey";
    STEP_PLAN_API_KEY = "stepKey";
    STEP_API_KEY = "stepKey";
    KIMI_API_KEY = "kimiCodeKey";
    TRIPO_API_KEY = "tripoKey";
    MACHGEN_API_KEY = "machgenKey";
    TYPESAFE_API_KEY = "typesafeKey";
    GMI_CLOUD_API_KEY = "gmiCloudKey";
    ZAI_CODING_CN_API_KEY = "zhipuKey";
    ZHIPUAI_API_KEY = "zhipuKey";
    MINIMAX_API_KEY = "minimaxKey";
    DEEPSEEK_API_KEY = "deepseekKey";
    OPENCODE_API_KEY = "opencodeGoKey";
    OPENAI_API_KEY = "pokeKey";
    ANTHROPIC_AUTH_TOKEN = "pokeKey";
  };

  # keys 之外的 key：本模块不 export，但需要 sops-nix 部署（给别处按路径直读）
  extraSecrets = [
    "aicodemirrorKey"
    "foxcodeKey"
    "rightcodeKey"
    "siliconflowKey"
    "zaiKey"
    "splitrailKey"
  ];
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
      ripgrep
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.zcode
      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.step-code
    ]
    ++ [
      inputs.cc-statusline.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.kimi-code.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.splitrail
      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.dsh
    ];

  home.file = utils.linkDotfiles [
    ".claude"
    # ".codex"
    ".dsh"
    ".kimi-code"
    ".pi"
    ".agents"
  ];
  xdg.configFile = utils.linkDotfiles [
    "opencode"
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

  sops.secrets = lib.genAttrs (lib.unique (lib.attrValues keys ++ extraSecrets)) (_: { });

  sops.templates."codex-auth.json" = {
    path = "${config.home.homeDirectory}/.codex/auth.json";
    content = builtins.toJSON {
      OPENAI_API_KEY = config.sops.placeholder.pokeKey;
    };
  };

  programs.zsh.initContent = lib.mkMerge [
    (lib.concatStringsSep "\n" (
      lib.mapAttrsToList (var: key: ''export ${var}="$(cat ${secret key})"'') keys
      ++ [
        "export OPENCODE_ENABLE_EXA=1"
        ''export OPENAI_BASE_URL="https://www.poke2api.com"''
        ''export ANTHROPIC_BASE_URL="https://www.poke2api.com"''
        "export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1"
        "export CLAUDE_CODE_ATTRIBUTION_HEADER=0"
        "export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1"
      ]
    ))
    (lib.mkIf (osConfig.networking.hostName == "aorus-nixos") (
      lib.mkOrder 1200 ''
        export CODE_DIR="/home/azurice/Files"
      ''
    ))
  ];
}
