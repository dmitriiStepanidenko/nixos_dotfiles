# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];
  boot = {
    initrd.availableKernelModules = ["nvme" "xhci_pci" "usb_storage" "usbhid" "sd_mod" "sdhci_pci"];
    initrd.kernelModules = [];
    kernelModules = ["kvm-amd"];
    extraModulePackages = [];
  };
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/aa2e6941-0c79-4ffa-aab7-425cc306b0cd";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/BADC-E961";
      fsType = "vfat";
      options = ["fmask=0022" "dmask=0022"];
    };

    "/home/dmitrii/shared" = {
      device = "/dev/disk/by-uuid/1757BB2B0F01D736";
      fsType = "ntfs";
      options = [
        "uid=1000"
        "gid=1000"
        "dmask=0022"
        "fmask=0022"
        "windows_names"
        "norecover"
        "big_writes"
        "streams_interface=windows"
        "inherit"
      ];
    };

    "/home/dmitrii/shared/tmp/gamechanger/target" = {
      device = "/dev/disk/by-label/gamechanger_t";
      depends = ["/home/dmitrii/shared"];
      fsType = "ext4";
      options = [
        "uid=1000"
        "gid=1000"
        "dmask=0022"
        "fmask=0022"
        "users"
        "nofail"
      ];
    };

    "/home/dmitrii/shared/tmp/graph-learning/target" = {
      device = "/dev/disk/by-label/graph_learning_t";
      depends = ["/home/dmitrii/shared"];
      fsType = "ext4";
      options = [
        "uid=1000"
        "gid=1000"
        "dmask=0022"
        "fmask=0022"
        "users"
        "nofail"
      ];
    };
  };
  services.smartd = {
    enable = true;
    devices = [
      {
        device = "/dev/disk/by-id/nvme-eui.0025384b3142ae19"; # FIXME: Change this to your actual disk
      }
    ];
  };
  environment.systemPackages = with pkgs; [
    smartmontools
  ];

  # mkswap: /dev/nvme0n1p7: warning: wiping old swap signature.
  # Setting up swapspace version 1, size = 16 GiB (17179865088 by
  # tes)
  # no label, UUID=a2840690-a68d-43e4-8dd0-6efa4b4958b6

  swapDevices = [
    {device = "/dev/disk/by-uuid/a2840690-a68d-43e4-8dd0-6efa4b4958b6";}
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp5s0f4u2u3c2.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp2s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
