{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: let
  unstable = import inputs.nixos-unstable {
    system = "x86_64-linux";
    config = {
      allowUnfree = true;
    };
  };
in {
  #imports = [
  #  "${inputs.nixos-unstable}/nixos/modules/services/hardware/amdgpu.nix"
  #];
  #disabledModules = ["services/hardware/amdgpu.nix"];

  boot.initrd.kernelModules = ["amdgpu"];
  boot.kernelParams = [
    "video=eDP-1:2560x1600@120"
    "video=HDMI-A-1:3440x1440@99"
  ];
  services.xserver.videoDrivers = [
    #"modesetting"
    "amdgpu"
    "nvidia"
  ];
  ###### GPU tweaks
  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    #powerManagement.enable = true;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = true;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = true;

    forceFullCompositionPipeline = false;

    # Enable the Nvidia settings menu,
    # accessible via `nviia-settings`.
    nvidiaSettings = true;

    package =
      config.boot.kernelPackages.nvidiaPackages.stable
      // {
        open = config.boot.kernelPackages.nvidiaPackages.stable.open.overrideAttrs (old: {
          patches =
            (old.patches or [])
            ++ [
              (pkgs.fetchpatch {
                name = "get_dev_pagemap.patch";
                url = "https://github.com/NVIDIA/open-gpu-kernel-modules/commit/3e230516034d29e84ca023fe95e284af5cd5a065.patch";
                hash = "sha256-BhL4mtuY5W+eLofwhHVnZnVf0msDj7XBxskZi8e6/k8=";
              })
            ];
        });
      };

    #package = config.boot.kernelPackages.nvidiaPackages.beta;
    #package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
    #  version = "580.95.05";
    #  sha256_64bit = "sha256-hJ7w746EK5gGss3p8RwTA9VPGpp2lGfk5dlhsv4Rgqc=";
    #  sha256_aarch64 = "sha256-zLRCbpiik2fGDa+d80wqV3ZV1U1b4lRjzNQJsLLlICk=";
    #  openSha256 = "sha256-RFwDGQOi9jVngVONCOB5m/IYKZIeGEle7h0+0yGnBEI=";
    #  settingsSha256 = "sha256-F2wmUEaRrpR1Vz0TQSwVK4Fv13f3J9NJLtBe4UP2f14=";
    #  persistencedSha256 = "sha256-QCwxXQfG/Pa7jSTBB0xD3lsIofcerAWWAHKvWjWGQtg=";
    #};

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      nvidiaBusId = "PCI:1:0:0";
      amdgpuBusId = "PCI:5:0:0";
    };
  };

  environment.systemPackages = with pkgs; [
    nvtopPackages.full
    nwg-displays # Choose monitor layout GUI

    geekbench
  ];

  #programs.coolercontrol = {
  #  enable = true;
  #};
  #programs.corectrl = {
  #  enable = true;
  #  gpuOverclock.enable = true;
  #};

  hardware.amdgpu = {
    initrd.enable = true;
    opencl.enable = true;
    overdrive.enable = true;
  };
}
