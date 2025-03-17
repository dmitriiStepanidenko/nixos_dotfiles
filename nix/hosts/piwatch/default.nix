{
  config,
  pkgs,
  lib,
  inputs,
  modulesPath,
  ...
}: {
  imports = [
    inputs.wireguard.nixosModules.default
    {
      services.wireguard = {
        enable = true;
        ips = "10.252.1.13/24";
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
    inputs.raspi-camera.nixosModules.raspi-camera # [4]
    #inputs.nixos-hardware.nixosModules.raspberry-pi-3
  ];

  config = {
    services.cloud-init.network.enable = false;
    services.cloud-init.enable = false;
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

    environment.systemPackages = with pkgs; [vim htop];

    networking = {
      useDHCP = true;
      hostName = "piwatch";
      wireless = {
        #environmentFile = config.sops.secrets."wifi.env".path;
        secretsFile = config.sops.secrets."wifi.conf".path;
        enable = true;
        interfaces = ["wlan0"];
        networks = {
          "zvezdnij" = {
            pskRaw = "ext:pass_home";
          };
        };
      };
    };

    # camera part

    #nixpkgs = {
    #  overlays = [
    #    (self: super: {
    #      # https://patchwork.libcamera.org/patch/19420
    #      libcamera = super.libcamera.overrideAttrs ({patches ? [], ...}: {
    #        patches =
    #          patches
    #          ++ [
    #            (self.fetchpatch {
    #              url = "https://patchwork.libcamera.org/patch/19420/raw";
    #              hash = "sha256-xJ8478CAKvyo2k1zrfIytDxFQ1Qdd8ilMdABQoNcdPU=";
    #            })
    #          ];
    #      });
    #    })
    #  ];
    #};

    # https://github.com/Electrostasy/dots/blob/3b81723feece67610a252ce754912f6769f0cd34/hosts/phobos/klipper.nix#L11
    #hardware.raspberry-pi."4".apply-overlays-dtmerge.enable = true;
    #hardware.deviceTree = {
    #  enable = true;
    #  filter = "bcm2837-rpi*.dtb";
    #  overlays = let
    #    # https://github.com/Electrostasy/dots/blob/3b81723feece67610a252ce754912f6769f0cd34/hosts/phobos/klipper.nix#L17-L42
    #    mkCompatibleDtsFile = dtbo: let
    #      # TODO: Make compatible with more than just bcm2837 (Raspberry Pi 3, Zero 2 W), e.g. Raspberry Pi 4 or 5.
    #      drv =
    #        (pkgs.runCommand (builtins.replaceStrings [".dtbo"] [".dts"] (baseNameOf dtbo)) {
    #          nativeBuildInputs = with pkgs; [dtc gnused];
    #        }) ''
    #          mkdir "$out"
    #          dtc -I dtb -O dts '${dtbo}' | sed -e 's/bcm2835/bcm2837/' > "$out/overlay.dts"
    #        '';
    #    in "${drv}/overlay.dts";
    #  in [
    #    # TODO: Support more cameras.
    #    {
    #      name = "imx708";
    #      dtsFile =
    #        mkCompatibleDtsFile "${config.boot.kernelPackages.kernel}/dtbs/overlays/imx708.dtbo";
    #    }

    #    # TODO: Find a better way to increase the CMA.
    #    # Real KMS does not work on the Raspberry Pi Zero 2 W.
    #    {
    #      name = "vc4-fkms-v3d";
    #      dtsFile = mkCompatibleDtsFile "${config.boot.kernelPackages.kernel}/dtbs/overlays/vc4-fkms-v3d.dtbo";
    #    }
    #  ];
    #};

    #services.udev.extraRules = ''
    #  # https://raspberrypi.stackexchange.com/a/141107
    #  SUBSYSTEM=="dma_heap", GROUP="video", MODE="0660"
    #'';

    #
    sops = {
      defaultSopsFile = ./secrets.yaml;
      defaultSopsFormat = "yaml";
      age = {
        sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
        keyFile = "/var/lib/sops-nix/key.txt";
        generateKey = true;
      };
      secrets = {
        "wifi.conf" = {
          owner = config.users.users.systemd-network.name;
          mode = "0400";
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
