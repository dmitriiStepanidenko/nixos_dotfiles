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
  ];
  config = {
    environment.systemPackages = [
      inputs.colmena.defaultPackage.${system}
    ];
    networking.firewall = {
      allowedUDPPorts = [
        8080
      ];
      allowedTCPPorts = [
        8080
      ];
      interfaces.wg0 = {
        allowedUDPPorts = [
          8080
          10600
        ];
        allowedTCPPorts = [
          8080
          10600
        ];
      };
    };
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
    };
    services.sccache-server = {
      enable = true;
      publicAddr = "127.0.0.1:10500";
      schedulerUrl = "https://sccache-scheduler.example.com";

      # Optionally customize cache settings
      cacheDir = "/var/lib/sccache/toolchains";
      toolchainCacheSize = 10737418240; # 10GB

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
