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
      };
    }
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
    ];
    networking = {
      firewall = {
        interfaces.wg0 = {
          allowedUDPPorts = [
            8000
            9000
          ];
          allowedTCPPorts = [
            8000
            9000
            22
          ];
        };
        enable = true;
        allowedTCPPorts = [22 8000 9000];
      };

      hostName = "woodpecker_server";
    };
    services.woodpecker-server = {
      enable = true;
      environmentFile = [config.sops.secrets."woodpecker_server".path];
      #package = inputs.nixpkgs-unstable.legacyPackages.${system}.woodpecker-server;
      package = pkgs.callPackage ../../packages/woodpecker-server.nix {};
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
