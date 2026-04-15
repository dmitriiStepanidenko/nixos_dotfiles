{
  inputs,
  pkgs,
  config,
  lib,
  machineRole,
  ...
}: let
  unstablePkgs = inputs.nixos-unstable.legacyPackages.${pkgs.system};

  cfg = config.services.opencodeWeb;

  validMachineRoles = [
    "laptop"
    "builder"
  ];

  openRouterApiKeySecretName = "opencode/${machineRole}/openrouter_api_key";
  omnirouteApiKeySecretName = "opencode/${machineRole}/omniroute_api_key";

  baseSecretNames = [
    openRouterApiKeySecretName
    "opencode/omniroute_base_url"
    omnirouteApiKeySecretName
    "opencode/lightrag_base_url"
    "opencode/lightrag_api_key"
  ];

  secretFile = name: "{file:${(config.sops.secrets.${name}).path}}";
in
  assert lib.assertMsg (lib.elem machineRole validMachineRoles) "nix/modules/home-manager/opencode.nix: machineRole must be one of ${lib.concatStringsSep ", " validMachineRoles}; got ${machineRole}"; {
    options.services.opencodeWeb = {
      enable = lib.mkEnableOption "OpenCode web user service";

      hostname = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
        description = "Hostname passed to `opencode web --hostname`.";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 4096;
        description = "Port passed to `opencode web --port`.";
      };

      username = lib.mkOption {
        type = lib.types.str;
        default = "opencode";
        description = "Username used together with OPENCODE_SERVER_PASSWORD.";
      };

      autoStart = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether Home Manager should install the service into default.target for autostart.";
      };

      passwordSecretName = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "opencode/builder/server_password";
        description = ''
          SOPS secret containing the raw password value for OPENCODE_SERVER_PASSWORD.
          Set this outside the shared module for each host that enables the web service.
        '';
      };
    };

    config = {
      assertions = [
        {
          assertion = !cfg.enable || cfg.passwordSecretName != null;
          message = "services.opencodeWeb.passwordSecretName must be set when services.opencodeWeb.enable is true.";
        }
      ];
      sops.secrets =
        lib.genAttrs baseSecretNames (_: {
          sopsFile = ./secrets.yaml;
          mode = "0400";
        })
        // lib.optionalAttrs cfg.enable {
          "${cfg.passwordSecretName}" = {
            sopsFile = ./secrets.yaml;
            mode = "0400";
          };
        };

      programs.opencode = {
        enable = true;
        package = unstablePkgs.opencode;
        settings = {
          "$schema" = "https://opencode.ai/config.json";
          model = "omniroute/default";
          small_model = "omniroute/default-lite";

          permission = {
            bash = {
              "sops" = "deny";
              "git" = "allow";
              "cargo" = "allow";
              "just" = "allow";
            };
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
              #models = {
              #};
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
                  options = {
                    include = ["reasoning.encrypted_content"];
                  };
                  variants = {
                    xhigh = {
                      reasoningEffort = "xhigh";
                      textVerbosity = "low";
                      reasoningSummary = "auto";
                    };
                    high = {
                      reasoningEffort = "high";
                      textVerbosity = "low";
                      reasoningSummary = "auto";
                    };
                    medium = {
                      reasoningEffort = "medium";
                      textVerbosity = "low";
                      reasoningSummary = "auto";
                    };
                    low = {
                      reasoningEffort = "low";
                      textVerbosity = "low";
                      reasoningSummary = "auto";
                    };
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

      systemd.user.services = lib.optionalAttrs cfg.enable {
        opencode-web = {
          Unit = {
            Description = "OpenCode web service";
            Wants = [
              "network.target"
              "sops-nix.service"
            ];
            After = [
              "network.target"
              "sops-nix.service"
            ];
          };

          Service = {
            Type = "simple";
            ExecStart = pkgs.writeShellScript "opencode-web-wrapper" ''
              export HOME=${lib.escapeShellArg config.home.homeDirectory}
              export OPENCODE_SERVER_USERNAME=${lib.escapeShellArg cfg.username}
              export OPENCODE_SERVER_PASSWORD="$(< ${lib.escapeShellArg config.sops.secrets.${cfg.passwordSecretName}.path})"
              exec ${lib.escapeShellArg "${config.programs.opencode.package}/bin/opencode"} web --hostname ${lib.escapeShellArg cfg.hostname} --port ${lib.escapeShellArg (toString cfg.port)}
            '';
            WorkingDirectory = config.home.homeDirectory;
            Restart = "on-failure";
            RestartSec = "5s";
          };

          Install = lib.mkIf cfg.autoStart {
            WantedBy = ["default.target"];
          };
        };
      };

      xdg.configFile = {
        "opencode/oh-my-openagent.json".source = ./opencode/oh-my-openagent.json;
        "opencode/dcp.jsonc".source = ./opencode/dcp.jsonc;
        "opencode/plugins/notification.js".source = ./opencode/plugins/notification.js;
        "opencode/prompts/TOOL-USAGE-POLICY.md".source = ./opencode/prompts/TOOL-USAGE-POLICY.md;
        "opencode/PROMPT-APPEND.md".source = ./opencode/PROMPT-APPEND.md;
      };
    };
  }
