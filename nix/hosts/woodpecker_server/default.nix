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
        ips = "10.252.1.5/24";
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
    inputs.buildbot-nix.nixosModules.buildbot-master
  ];
  config = {
    virtualisation = {
      oci-containers.backend = "docker";
      docker = {
        enable = true;
        autoPrune.enable = true;
        daemon.settings = {
          insecure-registries = ["10.252.1.8:5000"];
        };
      };
    };
    users.users.dmitrii.extraGroups = ["docker"];
    users.groups.docker = {};

    environment.systemPackages = [
      inputs.colmena.defaultPackage.${system}
      inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.nix-eval-jobs
    ];
    networking = {
      firewall = {
        interfaces.wg0 = {
          allowedUDPPorts = [
            8000
            9000
            44331
            9989
          ];
          allowedTCPPorts = [
            8000
            9000
            22
            44331
            9989
          ];
        };
        enable = true;
        allowedTCPPorts = [
          22
          8000
          9000
          44331
          9989
        ];
      };

      hostName = "woodpecker_server";
    };
    networking = {
      hosts = {
        "10.252.1.0" = ["dev.graph-learning.ru" "gitea.dev.graph-learning.ru"];
      };
    };
    services.woodpecker-server = {
      enable = true;
      environmentFile = [config.sops.secrets."woodpecker_server".path];
      package = inputs.nixpkgs-master.legacyPackages.${system}.woodpecker-server;
      #package = pkgs.callPackage ../../packages/woodpecker-server.nix {};
    };
    services.buildbot-master = {
      port = 44331;
      #buildbotUrl = "http://10.252.1.5:44331";
    };
    services.buildbot-nix.master = {
      enable = true;
      jobReportLimit = null;
      # optional nix-eval-jobs settings
      evalWorkerCount = 1; # limit number of concurrent evaluations
      evalMaxMemorySize = 14336; # limit memory usage per evaluation

      domain = "10.252.1.5:44331";
      admins = ["dmitrii"];
      buildSystems = ["x86_64-linux"];

      authBackend = "gitea";

      workersFile = config.sops.secrets."buildbot/worker_file".path;

      gitea = {
        enable = true;
        instanceUrl = "https://gitea.dev.graph-learning.ru";

        oauthId = "346d9747-2139-4b89-9f61-2b1cfe2e2c09";
        oauthSecretFile = config.sops.secrets."buildbot/gitea_client_secret".path;
        webhookSecretFile = config.sops.secrets."buildbot/gitea_webhook".path;

        tokenFile = config.sops.secrets."buildbot/gitea_token".path;

        #webhookSecretFile = pkgs.writeText "webhook-secret" "changeMe";
        #topic = "build-with-buildbot";
      };
      #extraConfig = ''
      #  c["www"] = {"pb": {"port": "tcp:44331:interface=\\:\\:"}}
      #'';
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
        "buildbot/gitea_webhook" = {
          mode = "0440";
          group = "buildbot";
          restartUnits = ["buildbot-master.service"];
        };
        "buildbot/worker_file" = {
          mode = "0440";
          group = "buildbot";
          restartUnits = ["buildbot-master.service"];
        };
        "buildbot/gitea_client_secret" = {
          mode = "0440";
          group = "buildbot";
          restartUnits = ["buildbot-master.service"];
        };
        "buildbot/gitea_token" = {
          mode = "0440";
          group = "buildbot";
          restartUnits = ["buildbot-master.service"];
        };
        "woodpecker_server" = {
          #inherit (config.users.users.docker) group;
          group = "docker";
          mode = "0440";
          restartUnits = ["woodpecker-server.service"];
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
