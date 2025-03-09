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
        ips = "10.252.1.6/24";
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
    environment.systemPackages = [
      inputs.colmena.defaultPackage.${system}
    ];
    networking.firewall = {
      allowedUDPPorts = [
        3000
      ];
      allowedTCPPorts = [
        3000
      ];
      interfaces.wg0 = {
        allowedUDPPorts = [
          3000
        ];
        allowedTCPPorts = [
          3000
        ];
      };
    };
    services.wakapi = {
      enable = true;
      passwordSaltFile = config.sops.secrets."wakapi/salt".path;
      package = pkgs.callPackage ../../packages/wakapi.nix {};
      database = {
        createLocally = true;
        dialect = "postgres";
        user = "wakapi";
        name = "wakapi";
      };
      settings = {
        app = {
          leaderboard_generation_time = "0 * * * * *";
          aggregation_time = "*/15 * * * * *";
        };
        security = {
          insecure_cookies = true;
        };
        server = {
          port = 3000;
          public_url = "http://10.252.1.6:3000";
          listen_ipv4 = "10.252.1.6";
        };
        db = {
          dialect = "postgres";
          user = "wakapi";
          name = "wakapi";
          host = "127.0.0.1";
          port = 5432;
        };
      };
    };

    networking.hostName = "wakapi";
    sops = {
      defaultSopsFile = ./secrets.yaml;
      defaultSopsFormat = "yaml";
      age = {
        sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
        keyFile = "/var/lib/sops-nix/key.txt";
        generateKey = true;
      };
      secrets = {
        "wakapi/salt" = {
          mode = "0440";
          owner = "wakapi";
          restartUnits = ["wakapi.service"];
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
