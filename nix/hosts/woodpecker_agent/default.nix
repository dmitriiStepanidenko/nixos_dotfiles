{
  config,
  pkgs,
  modulesPath,
  lib,
  system,
  ...
}: {

  imports = [
    ../../../nix/modules/wireguard.nix
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
      };
    }
    ../../../nix/modules/woodpecker_agent.nix
  ];

  config = {
    networking.hostName = "woodpecker_agent";
    sops = {
      defaultSopsFile = ./secrets.yaml;
      defaultSopsFormat = "yaml";
      age = {
        sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
        keyFile = "/var/lib/sops-nix/key.txt";
        generateKey = true;
      };
      secrets."wireguard/wireguard_ip" = {
        owner = config.users.users.systemd-network.name;
        mode = "0400";
      };
      secrets."wireguard/private_key" = {
        owner = config.users.users.systemd-network.name;
        mode = "0400";
      };
      secrets."wireguard/preshared_key" = {
        owner = config.users.users.systemd-network.name;
        mode = "0400";
      };
      secrets."wireguard/public_key" = {
        owner = config.users.users.systemd-network.name;
        mode = "0400";
      };
    };
  };
}
