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
  imports = [
    "${inputs.nixos-unstable}/nixos/modules/services/hardware/amdgpu.nix"
  ];
  disabledModules = ["services/hardware/amdgpu.nix"];

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

    #package = config.boot.kernelPackages.nvidiaPackages.beta;
    package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "580.76.05";
      sha256_64bit = "sha256-IZvmNrYJMbAhsujB4O/4hzY8cx+KlAyqh7zAVNBdl/0=";
      sha256_aarch64 = "sha256-NL2DswzVWQQMVM092NmfImqKbTk9VRgLL8xf4QEvGAQ=";
      openSha256 = "sha256-xEPJ9nskN1kISnSbfBigVaO6Mw03wyHebqQOQmUg/eQ=";
      settingsSha256 = "sha256-ll7HD7dVPHKUyp5+zvLeNqAb6hCpxfwuSyi+SAXapoQ=";
      persistencedSha256 = "sha256-bs3bUi8LgBu05uTzpn2ugcNYgR5rzWEPaTlgm0TIpHY=";
    };
    #package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
    #  version = "575.64.03";
    #  sha256_64bit = "sha256-S7eqhgBLLtKZx9QwoGIsXJAyfOOspPbppTHUxB06DKA=";
    #  sha256_aarch64 = "sha256-s2Jm2wjdmXZ2hPewHhi6hmd+V1YQ+xmVxRWBt68mLUQ=";
    #  openSha256 = "sha256-SAl1+XH4ghz8iix95hcuJ/EVqt6ylyzFAao0mLeMmMI=";
    #  settingsSha256 = "sha256-o8rPAi/tohvHXcBV+ZwiApEQoq+ZLhCMyHzMxIADauI=";
    #  persistencedSha256 = "sha256-/3OAZx8iMxQLp1KD5evGXvp0nBvWriYapMwlMSc57h8=";
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

  programs.coolercontrol = {
    enable = true;
  };
  programs.corectrl = {
    enable = true;
    gpuOverclock.enable = true;
  };

  hardware.amdgpu = {
    initrd.enable = true;
    opencl.enable = true;
    overdrive.enable = true;
    amdvlk.enable = true;
  };
}
