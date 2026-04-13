{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  #dataDir = "/data/webserver/root";
  homdeDir = "/home/woodpecker";
  dataDir = "${homdeDir}/data";
  unstable = import inputs.nixos-unstable {
    system = "x86_64-linux";
    config = {
      allowUnfree = true;
    };
  };
in {
  imports = [
    ../../modules/tmux.nix
    ../../modules/fpga_hardware.nix
    ../../modules/nix-ld.nix
    ./nix_builder.nix
    ./rag-pipeline.nix
    ./omniroute.nix
    inputs.wireguard.nixosModules.default
    {
      services.wireguard = {
        enable = true;
        ips = "10.252.1.22/24";
        privateKeyFile = config.sops.secrets."wireguard/private_key".path;
        peers = [
          {
            publicKeyFile = config.sops.secrets."wireguard/public_key".path;
            presharedKeyFile = config.sops.secrets."wireguard/preshared_key".path;
            allowedIPs = "10.252.1.0/24";
            endpointFile = config.sops.secrets."wireguard/wireguard_ip".path;
            endpointPort = 51820;
          }
        ];
        watchdog = {
          enable = true;
          pingIP = "10.252.1.0";
          interval = 30;
        };
      };
    }
  ];

  config = {
    services.ragPipeline = {
      enable = true;
      enableGpu = false; # ← CPU-only machine
      publiclyExpose = true;
      openRouterSopsSecret = "openrouter/env";
      lightragSopsSecret = "lightrag/auth";
      mineru = {
        enableLlmAided = true;
        #llmModel = "qwen/qwen3.6-plus:free";
        llmModel = "deepseek/deepseek-v3.2";
      };
    };
    services.omniroute = {
      enable = true;
      publiclyExpose = true; # only on the server if you want internet access
      envFile = config.sops.secrets."omniroute/env".path; # optional sops
    };
    i18n = {
      defaultLocale = "en_US.UTF-8";
      supportedLocales = [
        "en_US.UTF-8/UTF-8"
        "ru_RU.UTF-8/UTF-8"
      ];
    };
    networking = {
      hosts = {
        "10.252.1.0" = ["dev.graph-learning.ru" "gitea.dev.graph-learning.ru"];
      };
    };
    users.users.dmitrii = {
      shell = pkgs.fish;
      linger = true;
      extraGroups = [
        "input"
        "uinput"
        "tty"
        "dialout"
      ];
    };
    programs.fish.enable = true;
    systemd.tmpfiles.rules = [
      "d ${dataDir} 755 woodpecker nginx -"
      "d ${homdeDir} 755 woodpecker nginx -"
    ];
    programs.direnv.enable = true;
    system.stateVersion = lib.mkForce "25.11";
    environment.systemPackages = with pkgs; [
      serpl

      unstable.claude-code

      aider-chat-full
      nodejs_24

      nixos-firewall-tool

      libnotify
      notify

      lazygit

      btop
      htop

      google-chrome

      bun

      usbutils

      tree

      blisp

      inputs.daniel-lightrag-mcp.packages.${system}.default
    ];
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 45;
    };
    sops = {
      defaultSopsFile = ./secrets.yaml;
      defaultSopsFormat = "yaml";
      age = {
        sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
        keyFile = "/var/lib/sops-nix/key.txt";
        generateKey = true;
      };
      secrets = {
        "wireguard/wireguard_ip" = {
          owner = config.users.users.systemd-network.name;
          mode = "0400";
          restartUnits = ["wireguard-setup.service"];
        };
        "wireguard/private_key" = {
          owner = config.users.users.systemd-network.name;
          mode = "0400";
          restartUnits = ["wireguard-setup.service"];
        };
        "wireguard/preshared_key" = {
          owner = config.users.users.systemd-network.name;
          mode = "0400";
          restartUnits = ["wireguard-setup.service"];
        };
        "wireguard/public_key" = {
          owner = config.users.users.systemd-network.name;
          mode = "0400";
          restartUnits = ["wireguard-setup.service"];
        };
        "openrouter/env" = {
          owner = "root";
          group = "root";
          mode = "0400";
          restartUnits = ["podman-lightrag.service"];
        };
        "lightrag/auth" = {
          owner = "root";
          group = "root";
          mode = "0400";
          restartUnits = ["podman-lightrag.service"];
        };
        "omniroute/env" = {
          owner = "root";
          group = "root";
          mode = "0400";
        };
      };
    };
  };
}
