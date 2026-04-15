# omniroute.nix — Declarative OmniRoute AI Gateway (Podman)
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.omniroute;
in {
  options.services.omniroute = {
    enable = lib.mkEnableOption "OmniRoute — Smart LLM Router & AI Gateway";

    port = lib.mkOption {
      type = lib.types.port;
      default = 20128;
      description = "Port for OmniRoute API + Dashboard (default 20128)";
    };

    publiclyExpose = lib.mkEnableOption "Expose OmniRoute publicly (adds firewall rule)";

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/omniroute";
      description = "Persistent directory for SQLite DB, logs, settings, and MCP data";
    };

    # Optional: inject .env via sops (useful if you want to pre-seed some keys)
    envFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to .env file (can be a sops-managed secret)";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers.omniroute = {
      #image = "diegosouzapw/omniroute:3.5.1";
      image = "diegosouzapw/omniroute:3.6.5";
      autoStart = true;
      ports = ["${toString cfg.port}:20128"];
      volumes = ["${cfg.dataDir}:/app/data"];
      extraOptions = [
        "--restart=unless-stopped"
        "--stop-timeout=40" # required for clean SQLite WAL shutdown
      ];
      autoRemoveOnStop = false;

      environment = {
        PORT = "20128";
        ENABLE_REQUEST_LOGS = "true"; # Main request logging
        CALL_LOG_PIPELINE_ENABLED = "true"; # Exactly the four-stage payload capture
        # NEXT_PUBLIC_BASE_URL = "http://your-domain-or-ip:${toString cfg.port}"; # optional for OAuth
      };

      environmentFiles = lib.mkIf (cfg.envFile != null) [cfg.envFile];
    };

    # Create persistent data directory
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0755 root root -"
    ];

    # Firewall (only if you want it public)
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.publiclyExpose [cfg.port];

    environment.systemPackages = [pkgs.podman];
  };
}
