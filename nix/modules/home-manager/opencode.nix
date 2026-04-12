{
  inputs,
  pkgs,
  config,
  lib,
  machineRole,
  ...
}: let
  unstablePkgs = inputs.nixos-unstable.legacyPackages.${pkgs.system};

  validMachineRoles = [
    "laptop"
    "builder"
  ];

  openRouterApiKeySecretName = "opencode/${machineRole}/openrouter_api_key";
  omnirouteApiKeySecretName = "opencode/${machineRole}/omniroute_api_key";

  secretNames = [
    openRouterApiKeySecretName
    "opencode/omniroute_base_url"
    omnirouteApiKeySecretName
    "opencode/lightrag_base_url"
    "opencode/lightrag_api_key"
  ];

  secretFile = name: "{file:${(config.sops.secrets.${name}).path}}";
in
  assert lib.assertMsg (lib.elem machineRole validMachineRoles) "nix/modules/home-manager/opencode.nix: machineRole must be one of ${lib.concatStringsSep ", " validMachineRoles}; got ${machineRole}"; {
    sops.secrets = lib.genAttrs secretNames (_: {
      mode = "0400";
    });

    programs.opencode = {
      enable = true;
      package = unstablePkgs.opencode;
      settings = {
        "$schema" = "https://opencode.ai/config.json";
        model = "omniroute/default";
        small_model = "omniroute/default-lite";

        permission = {
          external_directory = {
            "/home/dmitrii/.config/opencode/prompts/**" = "allow";
            "~/.config/opencode/prompts/**" = "allow";
            "/home/dmitrii/opencode/prompts/**" = "allow";
            "~/opencode/prompts/**" = "allow";
          };
          edit = {
            "/home/dmitrii/.config/opencode/prompts/**" = "deny";
            "~/.config/opencode/prompts/**" = "deny";
            "/home/dmitrii/opencode/prompts/**" = "deny";
            "~/opencode/prompts/**" = "deny";
          };
          read = {
            "/home/dmitrii/.config/opencode/prompts/**" = "allow";
            "~/.config/opencode/prompts/**" = "allow";
            "/home/dmitrii/opencode/prompts/**" = "allow";
            "/home/dmitrii/tmp/thesis/PROMPT-APPEND.md" = "allow";
            "*.env" = "deny";
            "*.env.*" = "deny";
            "*.env.example" = "allow";
            "~/.ssh" = "deny";
            "secrets.yaml" = "deny";
          };
        };

        lsp = {
          spade-lsp = {
            command = [
              "spade-language-server"
              "--stdio"
            ];
            extensions = [
              ".spade"
            ];
          };
        };

        provider = {
          openrouter = {
            npm = "@ai-sdk/openai-compatible";
            name = "OpenRouter";
            options = {
              baseURL = "https://openrouter.ai/api/v1";
              apiKey = secretFile openRouterApiKeySecretName;
              headers = {
                "HTTP-Referer" = "https://opencode.ai";
                "X-OpenRouter-Title" = "OpenCode Agent";
              };
              websearch_cited = {
                model = "x-ai/grok-4.1-fast";
              };
            };
            models = {
              "minimax/minimax-m2.5" = {
                name = "Minimax M2.5";
                reasoning = true;
                cost = {
                  input = 0.2;
                  output = 1.2;
                };
              };
              "anthropic/claude-sonnet-4.6" = {
                name = "Anthropic: Claude Sonnet 4.6";
                reasoning = true;
                cost = {
                  input = 3;
                  output = 15;
                };
              };
              "deepseek/deepseek-v3.2-speciale" = {
                name = "DeepSeek v3.2 Speciale";
                reasoning = true;
                cost = {
                  input = 0.399;
                  output = 1.2;
                };
              };
              "deepseek/deepseek-v3.2" = {
                name = "DeepSeek v3.2";
                reasoning = true;
                cost = {
                  input = 0.214;
                  output = 0.45;
                };
              };
              "deepseek/deepseek-chat-v3.1" = {
                name = "DeepSeek Chat v3.1";
                reasoning = true;
                cost = {
                  input = 0.219;
                  output = 1.03;
                };
              };
              "deepseek/deepseek-chat" = {
                name = "DeepSeek Chat (V3)";
                reasoning = true;
                cost = {
                  input = 0.375;
                  output = 1.05;
                };
              };
              "anthropic/claude-3-5-sonnet-20241022" = {
                name = "Claude 3.5 Sonnet";
              };
            };
          };

          omniroute = {
            npm = "@ai-sdk/openai-compatible";
            name = "OmniRoute";
            options = {
              baseURL = secretFile "opencode/omniroute_base_url";
              apiKey = secretFile omnirouteApiKeySecretName;
            };
            models = {
              default = {
                name = "Default";
                limit = {
                  context = 1050000;
                  output = 128000;
                };
              };
              default-code = {
                name = "Default code";
                limit = {
                  context = 1050000;
                  output = 128000;
                };
              };
              default-lite = {
                name = "Default lite";
                limit = {
                  context = 400000;
                  output = 128000;
                };
              };
              default-search-fast = {
                name = "Default search fast";
                limit = {
                  context = 2000000;
                  output = 32768;
                };
              };
              "cx/gpt-5.4" = {
                name = "gpt-5.4";
                max_tokens = 300000;
              };
              "cx/gpt-5.4-mini" = {
                name = "gpt-5.4-mini";
                max_tokens = 300000;
              };
            };
          };
        };

        mcp = {
          playwright = {
            type = "local";
            command = [
              "bunx"
              "@playwright/mcp@latest"
              "--headless"
            ];
            enabled = true;
          };
          context7 = {
            type = "local";
            command = [
              "npx"
              "@upstash/context7-mcp@latest"
            ];
            enabled = true;
          };
          grep-app = {
            type = "local";
            command = [
              "npx"
              "grep-mcp@latest"
            ];
            enabled = true;
          };
          rag-mcp = {
            type = "local";
            command = [
              "env"
              "LIGHTRAG_BASE_URL=${secretFile "opencode/lightrag_base_url"}"
              "LIGHTRAG_API_KEY=${secretFile "opencode/lightrag_api_key"}"
              "LIGHTRAG_TIMEOUT=600"
              "daniel-lightrag-mcp"
            ];
            enabled = true;
          };
        };

        plugin = [
          "opencode-vibeguard"
          "opencode-pty"
          "opencode-websearch-cited@1.2.0"
          "@tarquinen/opencode-dcp@latest"
          "oh-my-openagent@latest"
        ];
      };
    };

    xdg.configFile = {
      "opencode/oh-my-openagent.json".source = ./opencode/oh-my-openagent.json;
      "opencode/dcp.jsonc".source = ./opencode/dcp.jsonc;
      "opencode/plugins/notification.js".source = ./opencode/plugins/notification.js;
      "opencode/prompts/TOOL-USAGE-POLICY.md".source = ./opencode/prompts/TOOL-USAGE-POLICY.md;
      "opencode/PROMPT-APPEND.md".source = ./opencode/PROMPT-APPEND.md;
    };
  }
