{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  #dataDir = "/data/webserver/root";
  homdeDir = "/home/woodpecker";
  dataDir = "${homdeDir}/data";
  unstable = import inputs.nixos-unstable {
    system = "x86_64-linux";
    config = {
      allowUnfree = true;
    };
  };
in {
  imports = [
    ../../modules/tmux.nix
    ../../modules/fpga_hardware.nix
    ./nix_builder.nix
    inputs.wireguard.nixosModules.default
    {
      services.wireguard = {
        enable = true;
        ips = "10.252.1.22/24";
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
    networking = {
      hosts = {
        "10.252.1.0" = ["dev.graph-learning.ru" "gitea.dev.graph-learning.ru"];
      };
    };
    users.users.dmitrii = {
      shell = pkgs.fish;
    };
    programs.fish.enable = true;
    systemd.tmpfiles.rules = [
      "d ${dataDir} 755 woodpecker nginx -"
      "d ${homdeDir} 755 woodpecker nginx -"
    ];
    programs.direnv.enable = true;
    system.stateVersion = lib.mkForce "25.11";
    environment.systemPackages = with pkgs; [
      serpl

      claude-code

      aider-chat-full

      unstable.opencode

      nixos-firewall-tool

      libnotify
      notify

      lazygit

      btop
      htop

      google-chrome

      bun

      usbutils
    ];
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 45;
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
