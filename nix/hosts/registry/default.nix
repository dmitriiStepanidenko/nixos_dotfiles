{
  config,
  inputs,
  ...
}: let
  kellnerDir = "/data/kellner";
in {
  imports = [
    inputs.wireguard.nixosModules.default
    {
      services.wireguard = {
        enable = true;
        ips = "10.252.1.8/24";
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
    systemd.tmpfiles.rules = [
      "d ${kellnerDir} 0755 root root -"
    ];
    networking.hostName = "container_registry";
    networking.firewall = {
      allowedUDPPorts = [
        22
        5000
      ];
      allowedTCPPorts = [
        22
        5000
      ];
      interfaces.wg0 = {
        allowedUDPPorts = [
          22
          5000
          8000
        ];
        allowedTCPPorts = [
          22
          5000
          8000
        ];
      };
    };
    virtualisation.oci-containers = {
      backend = "podman";
      containers = {
        kellner = {
          image = "ghcr.io/kellnr/kellnr:5";
          ports = ["8000:8000"];
          volumes = [
            "${kellnerDir}:/opt/kdata"
          ];
          environment = {
            KELLNR_DOCS__ENABLED = "true";
            KELLNR_ORIGIN__HOSTNAME = "10.252.1.8";
          };
        };
      };
    };
    systemd.services.docker-registry.serviceConfig = {
      Type = "simple";
      Restart = "on-failure";
      RestartSec = 5;
    };
    services.dockerRegistry = {
      enable = true;
      enableDelete = true;
      enableGarbageCollect = true;
      garbageCollectDates = "weekly";
      port = 5000;
      storagePath = "/var/lib/docker-registry";
      openFirewall = true;
      listenAddress = "10.252.1.8";
      extraConfig = {
        insecure-registries = ["10.252.1.8:5000"];
      };
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
      };
    };
  };
}
