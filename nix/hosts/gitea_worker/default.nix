{
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.wireguard.nixosModules.default
    {
      services.wireguard = {
        enable = true;
        ips = "10.252.1.4/24";
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
    ../../../nix/modules/gitea_action_runner.nix
  ];

  config = {
    networking.hostName = "gitea_worker";
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
      };
    };
  };
}
