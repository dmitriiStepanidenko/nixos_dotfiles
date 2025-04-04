{
  config,
  pkgs,
  lib,
  inputs,
  system,
  ...
}: {
  imports = [
    inputs.wireguard.nixosModules.default
    {
      services.wireguard = {
        enable = true;
        ips = "10.252.1.15/24";
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
    ./service.nix
  ];
  config = {
    services.openobserve = {
      enable = true;
      package = inputs.nixos-unstable.legacyPackages.${system}.openobserve;
      rootUser = {
        email = config.sops.secrets."openobserve/root_user/email".path;
        password = config.sops.secrets."openobserve/root_user/password".path;
      };
    };
    networking.firewall = {
      interfaces.wg0 = {
        allowedUDPPorts = [
          5080
          5081
        ];
        allowedTCPPorts = [
          5080
          5081
        ];
      };
    };

    networking.hostName = "openobserve";
    sops = {
      defaultSopsFile = ./secrets.yaml;
      defaultSopsFormat = "yaml";
      age = {
        sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
        keyFile = "/var/lib/sops-nix/key.txt";
        generateKey = true;
      };
      secrets = {
        "openobserve/root_user/password" = {
          owner = config.users.users.openobserve.name;
          mode = "0400";
          restartUnits = ["openobserve.service"];
        };
        "openobserve/root_user/email" = {
          owner = config.users.users.openobserve.name;
          mode = "0400";
          restartUnits = ["openobserve.service"];
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
