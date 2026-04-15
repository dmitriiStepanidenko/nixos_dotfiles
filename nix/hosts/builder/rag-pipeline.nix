# rag-pipeline.nix — declarative LightRAG + MinerU (Podman) + nix-sops support
# FINAL: mineru-openai-server is GPU-only (vLLM does not work reliably on CPU)
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.ragPipeline;

  mineru-src = pkgs.fetchFromGitHub {
    owner = "opendatalab";
    repo = "MinerU";
    rev = "mineru-3.0.8-released";
    hash = "sha256-SIni4JjN5TUqcvsZWu6fn14nuScKO5WLeRPx5Irzr7c=";
  };

  mineruJsonTemplate = pkgs.writeText "mineru.json" ''
    {
      "llm-aided-config": {
        "title_aided": {
          "api_key": "",
          "base_url": "https://openrouter.ai/api/v1",
          "model": "${cfg.mineru.llmModel}",
          "enable": ${
      if cfg.mineru.enableLlmAided
      then "true"
      else "false"
    }
        }
      },
      "models-dir": {
        "pipeline": "",
        "vlm": ""
      },
      "config_version": "1.3.1"
    }
  '';

  # === Shared settings (no duplication) ===
  commonVolumes = [
    "${cfg.dataDir}/mineru-output:/output"
    "${cfg.dataDir}/mineru-models:/root/.cache"
    "${cfg.dataDir}/mineru.json:/root/mineru.json:ro"
  ];

  commonExtraOptions = [
    "--network=mineru-net"
    "--restart=unless-stopped"
    "--dns=192.168.0.1"
    #"--dns=1.1.1.1"
    #"--dns=8.8.8.8"
  ];

  cpuEnv = {
    MINERU_MODEL_SOURCE = "huggingface";
    MINERU_DEVICE = "cpu";
    VLLM_CPU_MODE = "1";
    VLLM_DEVICE = "cpu";
    VLLM_USE_V1 = "0";
    CUDA_VISIBLE_DEVICES = "";
    VLLM_SKIP_WARMUP = "1";
    VLLM_LOGGING_LEVEL = "ERROR";
    MINERU_TOOLS_CONFIG_JSON = "/root/mineru.json";
  };
in {
  options.services.ragPipeline = {
    enable = lib.mkEnableOption "LightRAG + MinerU + RAG-Anything pipeline";
    enableGpu = lib.mkEnableOption "NVIDIA GPU passthrough (4 GB card)";
    publiclyExpose = lib.mkEnableOption "Expose LightRAG (9621), MinerU API (30000), Gradio (7860) and OpenAI-server (30001)";

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/rag-pipeline";
    };
    openRouterEnvFile = lib.mkOption {
      type = lib.types.path;
      default = "/etc/rag/openrouter.env";
    };
    openRouterSopsSecret = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
    lightragSopsSecret = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };

    mineru = {
      enableLlmAided = lib.mkEnableOption "LLM-aided title hierarchy post-processing" // {default = true;};
      llmModel = lib.mkOption {
        type = lib.types.str;
        default = "anthropic/claude-3.5-sonnet";
      };
      backend = lib.mkOption {
        type = lib.types.enum ["pipeline" "hybrid-auto-engine" "vlm-auto-engine"];
        default = "pipeline";
      };
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
          environmentFiles = let
            openRouterFile =
              if cfg.openRouterSopsSecret != null
              then [config.sops.secrets.${cfg.openRouterSopsSecret}.path]
              else [cfg.openRouterEnvFile];
            authFile =
              if cfg.lightragSopsSecret != null
              then [config.sops.secrets.${cfg.lightragSopsSecret}.path]
              else [];
          in
            openRouterFile ++ authFile;
          environment = {
            TOKEN_EXPIRE_HOURS = "168";
            GUEST_TOKEN_EXPIRE_HOURS = "24";
            MAX_GRAPH_NODES = "5000";
            GRAPH_VIEW_MAX_NODES = "3000";

            ### Max concurrency requests of LLM (for both query and document processing)
            # default 4
            MAX_ASYNC = "4";
            ### Number of parallel processing documents(between 2~10, MAX_ASYNC/3 is recommended)
            # default 2
            MAX_PARALLEL_INSERT = "2";
            ### Max concurrency requests for Embedding
            # default 8
            EMBEDDING_FUNC_MAX_ASYNC = "24";
            ### Num of chunks send to Embedding in single request
            # default 10
            EMBEDDING_BATCH_NUM = "10";

            OPENAI_LLM_MAX_COMPLETION_TOKENS = "12000";
            # default 9000
            LIGHTRAG_MAX_TOKENS = "12000";
            # default 9000
            OPENAI_LLM_MAX_TOKENS = "12000";
            LIGHTRAG_TEMPERATURE = "0.8";
            # none minimal low medium high xhigh
            OPENAI_LLM_REASONING_EFFORT = "xhigh";
            #OPENAI_LLM_EXTRA_BODY = "{'reasoning': {'enabled': false}}";

            # default 180
            LLM_TIMEOUT = "600";

            ### LLM request retry and timeout settings for evaluation
            # default 5
            EVAL_LLM_MAX_RETRIES = "15";

            EVAL_LLM_TIMEOUT = "600";

            ### Number of entities or relations retrieved from KG
            # default = 40
            TOP_K = "40";
            ### Maximum number or chunks for naive vector search
            # default = 20
            CHUNK_TOP_K = "20";
            ### control the actual entities send to LLM
            # default = 6000
            MAX_ENTITY_TOKENS = "6000";
            ### control the actual relations send to LLM
            # default =  8000
            MAX_RELATION_TOKENS = "8000";
            ### control the maximum tokens send to LLM (include entities, relations and chunks)
            # default =  30000
            MAX_TOTAL_TOKENS = "30000";

            ### Cohere rerank chunking configuration (useful for models with token limits like ColBERT)
            RERANK_ENABLE_CHUNKING = "false";
            #RERANK_MAX_TOKENS_PER_DOC = "480";

            #RELATED_CHUNK_NUMBER = "10";
          };
          extraOptions = ["--restart=unless-stopped"];
          autoRemoveOnStop = false;
        };

        mineru-openai = {
          image = "mineru:latest";
          autoStart = true;
          ports = ["30000:30000"];
          volumes = commonVolumes;
          extraOptions = commonExtraOptions;
          environment = cpuEnv // {MINERU_BACKEND = cfg.mineru.backend;};
          entrypoint = "mineru-api";
          cmd = ["--device" "cpu" "--host" "0.0.0.0" "--port" "30000"];
          autoRemoveOnStop = false;
        };

        mineru-gradio = {
          image = "mineru:latest";
          autoStart = true;
          ports = ["7860:7860"];
          volumes = [
            "${cfg.dataDir}/mineru-output:/output"
            "${cfg.dataDir}/mineru.json:/root/mineru.json:ro"
          ];
          extraOptions = commonExtraOptions;
          environment = {
            MINERU_TOOLS_CONFIG_JSON = "/root/mineru.json";
            LANG = "en_US.UTF-8";
            LANGUAGE = "en";
            LC_ALL = "en_US.UTF-8";
          };
          entrypoint = "mineru-gradio";
          cmd = ["--server-name" "0.0.0.0" "--server-port" "7860" "--api-url" "http://mineru-openai:30000"];
          autoRemoveOnStop = false;
        };

        # === mineru-openai-server is GPU-only (vLLM does not work on pure CPU) ===
        #mineru-openai-server = {
        #  image = "mineru:latest";
        #  autoStart = cfg.enableGpu;   # ← only starts when you enable GPU
        #  ports = ["30001:30001"];
        #  volumes = commonVolumes;
        #  extraOptions = commonExtraOptions ++ lib.optionals cfg.enableGpu [ "--device" "nvidia.com/gpu=all" ];
        #  environment = cpuEnv;
        #  entrypoint = "mineru-openai-server";
        #  cmd = ["--host" "0.0.0.0" "--port" "30001" "--device" "cpu"];
        #  autoRemoveOnStop = false;
        #};
      };
    };

    hardware.nvidia-container-toolkit.enable = lib.mkIf cfg.enableGpu true;

    networking.firewall.allowedTCPPorts = lib.optionals cfg.publiclyExpose [9621 30000 7860 30001];

    # Shared network
    systemd.services.podman-mineru-network = {
      description = "Create MinerU shared network";
      wantedBy = ["multi-user.target"];
      before = ["podman-mineru-openai.service" "podman-mineru-gradio.service"]; #"podman-mineru-openai-server.service"];
      serviceConfig.Type = "oneshot";
      script = ''
        if ! ${pkgs.podman}/bin/podman network exists mineru-net 2>/dev/null; then
          ${pkgs.podman}/bin/podman network create mineru-net
        fi
      '';
    };

    # MinerU config
    systemd.services.mineru-config = {
      description = "Generate MinerU config";
      wantedBy = ["multi-user.target"];
      before = ["podman-mineru-openai.service"];
      serviceConfig.Type = "oneshot";
      script = ''
        mkdir -p ${cfg.dataDir}
        API_KEY=""
        if [ -n "${toString cfg.openRouterSopsSecret}" ] && [ -f "${config.sops.secrets.${cfg.openRouterSopsSecret}.path or "/dev/null"}" ]; then
          API_KEY=$(grep -oP 'OPENROUTER_API_KEY=\K.*' ${config.sops.secrets.${cfg.openRouterSopsSecret}.path} 2>/dev/null || echo "")
        fi
        if [ -z "$API_KEY" ] && [ -f "${cfg.openRouterEnvFile}" ]; then
          API_KEY=$(grep -oP 'OPENROUTER_API_KEY=\K.*' ${cfg.openRouterEnvFile} 2>/dev/null || echo "")
        fi
        if [ -n "$API_KEY" ]; then
          ${pkgs.jq}/bin/jq --arg key "$API_KEY" '.["llm-aided-config"].title_aided.api_key = $key' ${mineruJsonTemplate} > ${cfg.dataDir}/mineru.json
        else
          cp ${mineruJsonTemplate} ${cfg.dataDir}/mineru.json
        fi
        chmod 600 ${cfg.dataDir}/mineru.json
      '';
    };

    systemd.services.podman-mineru-openai = {
      preStart = lib.mkBefore ''
        echo "=== Checking MinerU image ==="
        if ! ${pkgs.podman}/bin/podman image exists mineru:latest; then
          echo "Building MinerU..."
          ${pkgs.podman}/bin/podman build -f ${mineru-src}/docker/global/Dockerfile -t mineru:latest ${mineru-src}
        fi
      '';
      after = ["mineru-config.service" "podman-mineru-network.service"];
      requires = ["mineru-config.service" "podman-mineru-network.service"];
    };

    systemd.services.podman-mineru-gradio.after = ["mineru-config.service" "podman-mineru-openai.service" "podman-mineru-network.service"];
    #systemd.services.podman-mineru-openai-server.after = ["mineru-config.service" "podman-mineru-network.service"];

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir}/lightrag-rag_storage 0755 root root -"
      "d ${cfg.dataDir}/lightrag-inputs 0755 root root -"
      "d ${cfg.dataDir}/mineru-output 0755 root root -"
      "d ${cfg.dataDir}/mineru-models 0755 root root -"
      "d ${cfg.dataDir} 0755 root root -"
      "d /etc/rag 0755 root root -"
    ];

    environment.systemPackages = with pkgs; [podman jq];
  };
}
