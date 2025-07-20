{
  config,
  pkgs,
  lib,
  inputs,
  system,
  ...
}: {
  options.woodpecker_agent.package = lib.mkOption {
    type = lib.types.package;
    default = pkgs.woodpecker-agent;
  };
  imports = [
    inputs.wireguard.nixosModules.default
    {
      services.wireguard = {
        enable = true;
        ips = "10.252.1.7/24";
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
    ../../../nix/modules/woodpecker_agent.nix
    #inputs.sccache.nixosModules.default # Import all three modules
    inputs.sccache.nixosModules.sccache_dist_scheduler
    inputs.sccache.nixosModules.sccache_dist_build_server
    inputs.buildbot-nix.nixosModules.buildbot-worker
  ];
  config = {
    environment.systemPackages = [
      inputs.colmena.defaultPackage.${system}
      inputs.buildbot-nix.packages.${system}.buildbot-effects
      inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.nix-eval-jobs
    ];
    networking.firewall = {
      allowedUDPPorts = [
        8080
        10500
        10600
      ];
      allowedTCPPorts = [
        8080
        10500
        10600
      ];
      interfaces.wg0 = {
        allowedUDPPorts = [
          8080
          10600
          10500
          10501
          3005
          55655
          5678
          8889
        ];
        allowedTCPPorts = [
          8080
          10600
          10500
          10501
          3005
          55655
          5678
          8889
        ];
      };
    };
    # I have partition for that
    #swapDevices = [
    #  {
    #    device = "/swapfile";
    #    size = 32 * 1024; # 32GB
    #    priority = 0;
    #  }
    #];
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 15;
    };
    networking = {
      hosts = {
        "10.252.1.0" = ["dev.graph-learning.ru" "gitea.dev.graph-learning.ru"];
      };
    };
    services.buildbot-nix.worker = {
      enable = true;
      name = "woodpecker_agent";
      workerPasswordFile = config.sops.secrets."buildbot/worker_pass".path;
      masterUrl = "tcp:host=10.252.1.5:port=9989";
    };
    services.n8n = {
      enable = true;
      settings = {
        port = 5678;
        editorBaseUrl = "http://10.252.1.7:5678";
      };
      webhookUrl = "http://10.252.1.7:5678";
    };
    services.windmill = {
      enable = true;
      serverPort = 8889;
      baseUrl = "http://10.252.1.7:8889";
    };
    systemd.services.n8n.environment = {
      N8N_SECURE_COOKIE = "false";
    };
    services.hydra = {
      enable = true;
      hydraURL = "http://10.252.1.7:3005";
      notificationSender = "hydra@localhost";
      buildMachinesFiles = [];
      useSubstitutes = true;
      port = 3005;
      extraConfig = ''
        Include ${config.sops.secrets."hydra/gitea_authorizations.conf".path}
        <dynamicruncommand>
                enable = 1
        </dynamicruncommand>

      '';
      #package = inputs.nixpkgs-unstable.legacyPackages.${system}.hydra;
    };
    #nix.extraOptions = ''
    #  allowed-uris = https://github.com/ http://10.252.1.0:3000/
    #'';

    nix.settings = {
      allowed-uris = [
        "github:"
        "github:NixOS/nixpkgs"
        "git+https://github.com/"
        "git+ssh://github.com/"
        "git+http://10.252.1.0:3000/"
      ];
      # Disable extra on this server
      extra-substituters = [
      ];
      trusted-users = ["root" "dmitrii" "@trusted"];
      extra-trusted-public-keys = [
      ];
    };
    users.groups.trusted = {};
    users.users.nix-serve = {
      isSystemUser = true;
      group = "nix-serve";
    };
    services.nix-serve = {
      enable = true;
      #secretKeyFile = "/var/cache-priv-key.pem";
      secretKeyFile = config.sops.secrets."nix-serve/cache-priv-key.pem".path;
      port = 55655;
    };
    nix = {
      optimise.automatic = true;
      gc = {
        automatic = true;
        dates = "5:40";
        options = "--delete-older-than 2d";
      };
      extraOptions = ''
        min-free = ${toString (10 * 1024 * 1024 * 1024)}
        max-free = ${toString (10 * 1024 * 1024 * 1024)}
      ''; # Free up 10GiB whenever there is less than 10 GiB left
    };

    users = {
      users = {
        "danila" = {
          isNormalUser = true;
          group = "danila";
          extraGroups = ["wheel" "docker" "networkmanager"];
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDJslEEcZRowrww4X14nnTwUODSpQLH9ZenX8Co0hfbJ danila@danila-vostro"
          ];
        };
      };
      groups.danila = {};
    };

    users.groups.nix-serve = {};
    services.sccache-scheduler = {
      enable = true;
      listenAddr = "10.252.1.7:10600";
      clientAuth = {
        type = "token";
        tokenFile = config.sops.secrets."sccache/client_token".path;
      };
      serverAuth = {
        type = "jwt_hs256";
        secretKeyFile = config.sops.secrets."sccache/server_key".path;
      };
      syslog = "trace";
    };
    services.sccache-server = {
      enable = true;
      syslog = "trace";
      publicAddr = "10.252.1.7:10500";
      schedulerUrl = "http://10.252.1.7:10600";

      # Optionally customize cache settings
      cacheDir = "/var/lib/sccache/toolchains";
      toolchainCacheSize = 1024 * 1024 * 1024 * 3; # 10GB * 3 = 30 GB

      # Builder configuration
      builder = {
        type = "overlay";
        buildDir = "/var/lib/sccache/build";
        # bubblewrap path is set to the NixOS package by default
      };

      # Authentication with the scheduler
      schedulerAuth = {
        type = "jwt_token";
        tokenFile = config.sops.secrets."sccache/server_token".path;
        #type = "token";
        #tokenFile = config.sops.secrets."sccache/client_token".path;
      };

      # Any additional configuration
      extraConfig = {
        # Add any other config sections or values here
      };
    };

    # Configure the sccache build server
    services.atticd = {
      enable = true;
      environmentFile = config.sops.secrets."attic/environment".path;
      settings = {
        listen = "[::]:8080";
        jwt = {};
        # Data chunking
        #
        # Warning: If you change any of the values here, it will be
        # difficult to reuse existing chunks for newly-uploaded NARs
        # since the cutpoints will be different. As a result, the
        # deduplication ratio will suffer for a while after the change.
        chunking = {
          # The minimum NAR size to trigger chunking
          #
          # If 0, chunking is disabled entirely for newly-uploaded NARs.
          # If 1, all NARs are chunked.
          nar-size-threshold = 64 * 1024; # 64 KiB

          # The preferred minimum size of a chunk, in bytes
          min-size = 16 * 1024; # 16 KiB

          # The preferred average size of a chunk, in bytes
          avg-size = 64 * 1024; # 64 KiB

          # The preferred maximum size of a chunk, in bytes
          max-size = 256 * 1024; # 256 KiB
        };
      };
    };

    networking.hostName = "woodpecker_agent";
    sops = {
      defaultSopsFile = ./secrets.yaml;
      defaultSopsFormat = "yaml";
      age = {
        sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
        keyFile = "/var/lib/sops-nix/key.txt";
        generateKey = true;
      };
      secrets = {
        "buildbot/worker_pass" = {
          mode = "0440";
          group = "buildbot-worker";
          restartUnits = ["buildbot-worker.service"];
        };
        "nix-serve/cache-priv-key.pem" = {
          group = "nix-serve";
          mode = "0440";
          #restartUnits = ["hydra-server.service"];
        };
        "hydra/gitea_authorizations.conf" = {
          group = "hydra";
          mode = "0440";
        };
        "sccache/server_token" = {
          owner = "root";
          mode = "0400";
          restartUnits = ["sccache-server.service"];
        };
        "sccache/server_key" = {
          owner = config.users.users.sccache.name;
          mode = "0440";
          restartUnits = ["sccache-scheduler.service"];
        };
        "sccache/client_token" = {
          owner = config.users.users.sccache.name;
          mode = "0440";
          restartUnits = ["sccache-scheduler.service"];
        };
        "attic/environment" = {
          mode = "0440";
          restartUnits = ["atticd.service"];
        };
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
      };
    };
  };
}
