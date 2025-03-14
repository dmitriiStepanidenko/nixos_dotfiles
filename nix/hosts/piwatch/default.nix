{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    #inputs.wireguard.nixosModules.default
    #{
    #  services.wireguard = {
    #    enable = true;
    #    ips = "10.252.1.9/24";
    #    privateKeyFile = config.sops.secrets."wireguard/private_key".path;
    #    peers = [
    #      {
    #        publicKeyFile = config.sops.secrets."wireguard/public_key".path;
    #        presharedKeyFile = config.sops.secrets."wireguard/preshared_key".path;
    #        allowedIPs = "10.252.1.0/24";
    #        endpointFile = config.sops.secrets."wireguard/wireguard_ip".path;
    #        endpointPort = 51820;
    #      }
    #    ];
    #    watchdog = {
    #      enable = true;
    #      pingIP = "10.252.1.0";
    #      interval = 30;
    #    };
    #  };
    #}
  ];

  config = {
    hardware.enableRedistributableFirmware = true;
    system.stateVersion = "24.11";
    boot = {
      kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
      initrd.availableKernelModules = ["xhci_pci" "usbhid" "usb_storage"];
      loader = {
        grub.enable = false;
        generic-extlinux-compatible.enable = true;
      };
    };

    fileSystems = {
      "/" = {
        device = "/dev/disk/by-label/NIXOS_SD";
        fsType = "ext4";
        options = ["noatime"];
      };
    };

    environment.systemPackages = with pkgs; [vim];

    networking = {
      hostName = "piwatch";
      wireless = {
        environmentFile = config.sops.secrets."wifi.env".path;
        enable = true;
        interfaces = ["wlan0"];
        networks = {
          "@ssid@" = {
            psk = "@pass@";
          };
        };
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
        "wifi.env" = {};
        #"wireguard/wireguard_ip" = {
        #  owner = config.users.users.systemd-network.name;
        #  mode = "0400";
        #  restartUnits = ["wireguard-setup.service"];
        #};
        #"wireguard/private_key" = {
        #  owner = config.users.users.systemd-network.name;
        #  mode = "0400";
        #  restartUnits = ["wireguard-setup.service"];
        #};
        #"wireguard/preshared_key" = {
        #  owner = config.users.users.systemd-network.name;
        #  mode = "0400";
        #  restartUnits = ["wireguard-setup.service"];
        #};
        #"wireguard/public_key" = {
        #  owner = config.users.users.systemd-network.name;
        #  mode = "0400";
        #  restartUnits = ["wireguard-setup.service"];
        #};
      };
    };
  };
}
