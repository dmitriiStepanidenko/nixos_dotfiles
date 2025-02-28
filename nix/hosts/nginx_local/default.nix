{
  config,
  pkgs,
  modulesPath,
  lib,
  system,
  ...
}: let
  dataDir = "/data/webserver/root";
in {
  imports = [
    ../../../nix/modules/wireguard.nix
    {
      services.wireguard = {
        enable = true;
        ips = "10.252.1.9/24";
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
    networking.hostName = "container_registry";
    services.sftpgo = {
      enable = true;
      inherit dataDir;
      settings.httpd.bindings.default = {
        address = "10.252.1.9";
        port = "8080";
      };
    };
    services.nginx.virtualHosts.default = {
      enable = true;
      default = true;
      data = dataDir;
      listen = [
        {
          addr = "10.252.1.9";
          port = "80";
          ssl = false;
        }
      ];
    };
    sops = {
      defaultSopsFile = ./secrets.yaml;
      defaultSopsFormat = "yaml";
      age = {
        #keyFilePaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
        keyFile = "/var/lib/sops-nix/key.txt";
        generateKey = true;
      };
      secrets = {
        "wireguard/wireguard_ip" = {
          owner = config.users.users.systemd-network.name;
          mode = "0400";
        };
        "wireguard/private_key" = {
          owner = config.users.users.systemd-network.name;
          mode = "0400";
        };
        "wireguard/preshared_key" = {
          owner = config.users.users.systemd-network.name;
          mode = "0400";
        };
        "wireguard/public_key" = {
          owner = config.users.users.systemd-network.name;
          mode = "0400";
        };
      };
    };
  };
}
