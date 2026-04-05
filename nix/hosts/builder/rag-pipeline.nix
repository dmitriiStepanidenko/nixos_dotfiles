# rag-pipeline.nix — declarative LightRAG + MinerU (Podman) + nix-sops support
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.ragPipeline;

  # === MinerU source (latest stable release) ===
  mineru-src = pkgs.fetchFromGitHub {
    owner = "opendatalab";
    repo = "MinerU";
    rev = "mineru-3.0.8-released";
    hash = "sha256-SIni4JjN5TUqcvsZWu6fn14nuScKO5WLeRPx5Irzr7c=";
  };
in {
  options.services.ragPipeline = {
    enable = lib.mkEnableOption "LightRAG + MinerU + RAG-Anything pipeline";
    enableGpu = lib.mkEnableOption "NVIDIA GPU passthrough (4 GB card)";
    publiclyExpose = lib.mkEnableOption "Expose LightRAG (9621) and MinerU (30000) to the public internet";
    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/rag-pipeline";
      description = "Base directory for persistent volumes";
    };

    # === OpenRouter ===
    openRouterEnvFile = lib.mkOption {
      type = lib.types.path;
      default = "/etc/rag/openrouter.env";
      description = "Fallback path if not using sops";
    };
    openRouterSopsSecret = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "openrouter/env";
      description = "sops secret name (takes priority over openRouterEnvFile)";
    };

    # === NEW: LightRAG built-in auth via sops ===
    lightragSopsSecret = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "lightrag/auth";
      description = ''
        sops secret name for LightRAG password protection.
        Content example (plain text in your sops file):
          AUTH_ACCOUNTS=admin:YourSuperStrongPassword2026
          LIGHTRAG_API_KEY=sk-lightrag-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
          TOKEN_SECRET=change-this-to-a-very-long-random-string-at-least-64-chars-2026
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation = {
      podman.enable = true;
      podman.dockerCompat = true;
      oci-containers.backend = "podman";
      oci-containers.containers = {
        lightrag = {
          image = "ghcr.io/hkuds/lightrag:latest";
          autoStart = true;
          ports = ["9621:9621"];
          volumes = [
            "${cfg.dataDir}/lightrag-rag_storage:/app/data/rag_storage"
            "${cfg.dataDir}/lightrag-inputs:/app/data/inputs"
          ];

          # === Combined sops + fallback files ===
          environmentFiles =
            let
              openRouterFile =
                if cfg.openRouterSopsSecret != null
                then [config.sops.secrets.${cfg.openRouterSopsSecret}.path]
                else [cfg.openRouterEnvFile];
              lightragAuthFile =
                if cfg.lightragSopsSecret != null
                then [config.sops.secrets.${cfg.lightragSopsSecret}.path]
                else [];
            in
              openRouterFile ++ lightragAuthFile;

          # Non-sensitive defaults (can be overridden by sops)
          environment = {
            TOKEN_EXPIRE_HOURS = "168";      # 7 days
            GUEST_TOKEN_EXPIRE_HOURS = "24";
          };

          extraOptions = ["--restart=unless-stopped"];
          autoRemoveOnStop = false;
        };

        mineru-openai = {
          image = "mineru:latest";
          autoStart = true;
          ports = ["30000:30000"];
          volumes = ["${cfg.dataDir}/mineru-output:/output"];
          extraOptions = ["--restart=unless-stopped"];
          autoRemoveOnStop = false;
          # Strong CPU-only configuration (90 GB RAM machine)
          environment = {
            MINERU_MODEL_SOURCE = "local";
            MINERU_BACKEND = "pipeline";
            MINERU_DEVICE = "cpu";
            VLLM_CPU_MODE = "1";
            VLLM_DEVICE = "cpu";
            VLLM_USE_V1 = "0";
            CUDA_VISIBLE_DEVICES = "";
            VLLM_SKIP_WARMUP = "1";
            VLLM_LOGGING_LEVEL = "ERROR";
          };
          entrypoint = "mineru-api";
          cmd = ["--backend" "pipeline" "--device" "cpu" "--host" "0.0.0.0" "--port" "30000"];
        };
      };
    };

    hardware.nvidia-container-toolkit.enable = lib.mkIf cfg.enableGpu true;

    networking.firewall.allowedTCPPorts = lib.optionals cfg.publiclyExpose [9621 30000];

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir}/lightrag-rag_storage 0755 root root -"
      "d ${cfg.dataDir}/lightrag-inputs 0755 root root -"
      "d ${cfg.dataDir}/mineru-output 0755 root root -"
      "d /etc/rag 0755 root root -"
    ];

    # Automatic MinerU build
    systemd.services.podman-mineru-openai = {
      preStart = lib.mkBefore ''
        echo "=== Checking MinerU image ==="
        if ! ${pkgs.podman}/bin/podman image exists mineru:latest; then
          echo "Building MinerU ${mineru-src.rev}..."
          ${pkgs.podman}/bin/podman build \
            -f ${mineru-src}/docker/global/Dockerfile \
            -t mineru:latest \
            ${mineru-src}
          echo "MinerU image built successfully."
        else
          echo "MinerU image already exists — skipping build."
        fi
      '';
    };

    environment.systemPackages = with pkgs; [podman];
  };
}
