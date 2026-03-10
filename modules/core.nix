{
  system,
  mac,
  config,
  pkgs,
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
      foxcodeKey = {
        owner = "azurice";
      };
      opencodeGoKey = {
        owner = "azurice";
      };
      zaiKey = {
        owner = "azurice";
      };
      splitrailKey = {
        owner = "azurice";
      };
    };
  };

  programs.zsh.shellInit =
    let
      aicodemirrorKey = config.sops.secrets.aicodemirrorKey.path;
      foxcodeKey = config.sops.secrets.foxcodeKey.path;
      zaiKey = config.sops.secrets.zaiKey.path;
      rightcodeKey = config.sops.secrets.rightcodeKey.path;

      # ANTHROPIC Provider Configurations
      anthropicProviders = {
        foxcode-aws = {
          baseUrl = "https://code.newcli.com/claude/aws";
          authTokenFile = foxcodeKey;
          extraVars = { };
        };
        foxcode = {
          baseUrl = "https://code.newcli.com/claude";
          authTokenFile = foxcodeKey;
          extraVars = { };
        };
        zai = {
          baseUrl = "https://api.z.ai/api/anthropic";
          authTokenFile = zaiKey;
          extraVars = {
            ANTHROPIC_DEFAULT_HAIKU_MODEL = "glm-4.5-Air";
            ANTHROPIC_DEFAULT_SONNET_MODEL = "glm-4.7";
            ANTHROPIC_DEFAULT_OPUS_MODEL = "glm-5";
            ANTHROPIC_MODEL = "glm-5";
          };
        };
        rightcode-aws = {
          baseUrl = "https://right.codes/claude-aws";
          authTokenFile = rightcodeKey;
          extraVars = { };
        };
        rightcode-sale = {
          baseUrl = "https://right.codes/claude-sale";
          authTokenFile = rightcodeKey;
          extraVars = { };
        };
        rightcode = {
          baseUrl = "https://right.codes/claude-sale";
          authTokenFile = rightcodeKey;
          extraVars = { };
        };
        aicodemirror = {
          baseUrl = "https://api.claudecode.net.cn/api/claudecode";
          authTokenFile = aicodemirrorKey;
          extraVars = { };
        };
      };

      # Generate shell function for a provider
      mkProviderFunction = name: cfg: ''
        _cc_${name}() {
          export ANTHROPIC_BASE_URL="${cfg.baseUrl}"
          export ANTHROPIC_AUTH_TOKEN="$(cat ${cfg.authTokenFile})"
          ${lib.concatStringsSep "\n  " (lib.mapAttrsToList (k: v: "export ${k}=\"${v}\"") cfg.extraVars)}
          ${lib.optionalString (cfg.extraVars == { })
            "unset ANTHROPIC_DEFAULT_HAIKU_MODEL ANTHROPIC_DEFAULT_SONNET_MODEL ANTHROPIC_DEFAULT_OPUS_MODEL ANTHROPIC_MODEL 2>/dev/null"
          }
          echo "Switched to ${name}"
        }
      '';

      # Generate all provider functions
      providerFunctions = lib.concatStringsSep "\n" (
        lib.mapAttrsToList mkProviderFunction anthropicProviders
      );

      # Generate the cc-switch command
      ccSwitchCommand = ''
        cc-switch() {
          # Show status if no argument
          if [ -z "$1" ]; then
            echo "Current: ANTHROPIC_BASE_URL=$ANTHROPIC_BASE_URL"
            echo ""
            echo "Available providers:"
            ${lib.concatStringsSep "\n            " (
              map (name: ''echo "  ${name}"'') (lib.attrNames anthropicProviders)
            )}
            return 0
          fi

          case "$1" in
            ${lib.concatStringsSep "\n    " (
              lib.mapAttrsToList (name: _: ''"${name}") _cc_${name} ;;'') anthropicProviders
            )}
            *)
              echo "Unknown provider: $1"
              echo "Available providers:"
              ${lib.concatStringsSep "\n              " (
                map (name: ''echo "  ${name}"'') (lib.attrNames anthropicProviders)
              )}
              return 1
              ;;
          esac
        }
      '';

      minimaxKey = config.sops.secrets.minimaxKey.path;

      lib = pkgs.lib;

      # Generate zsh completion for cc-switch
      providerNames = lib.concatStringsSep " " (lib.attrNames anthropicProviders);
      ccSwitchCompletion = ''
        _cc-switch() {
          local -a providers
          providers=(${providerNames})
          _describe 'provider' providers
        }
        compdef _cc-switch cc-switch
      '';
    in
    ''
      export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
      export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
      export OPENCODE_ENABLE_EXA=1

      # Other API Keys
      export MINIMAX_API_KEY="$(cat ${minimaxKey})"
      export GOOGLE_GEMINI_BASE_URL="https://api.claudecode.net.cn/api/gemini"
      export GEMINI_API_KEY="$(cat ${aicodemirrorKey})"
      export OPENAI_BASE_URL="https://api.claudecode.net.cn/api/codex/backend-api/codex"
      export OPENAI_API_KEY="$(cat ${aicodemirrorKey})"

      ${providerFunctions}

      ${ccSwitchCommand}

      ${ccSwitchCompletion}

      # Default: use foxcode-aws
      _cc_foxcode-aws
    '';
}
