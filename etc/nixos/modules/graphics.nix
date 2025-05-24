{
  lib,
  pkgs,
  config,
  ...
}: {
  boot.initrd.kernelModules = ["amdgpu"];
  boot.kernelParams = [
    "video=eDP-1:2560x1600@120"
  ];
  services.xserver.videoDrivers = [
    "amdgpu"
    "modesetting"
    "fbdev"
    "nvidia"
  ];
  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = true;

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

    # Optionally, you may need to select the appropriate driver version for your specific GPU.

    # downgrade to 535 because: https://forums.developer.nvidia.com/t/series-550-freezes-laptop/284772/214
    #package = config.boot.kernelPackages.nvidiaPackages.legacy_535;
    #package = config.boot.kernelPackages.nvidiaPackages.beta;
    package = config.boot.kernelPackages.nvidiaPackages.latest;

    #package = (inputs.nixpkgsunstable.linuxPackagesFor config.boot.kernelPackages.kernel).nvidiaPackages.legacy_535;
    #package = (linuxPackagesFor inputs.nixpkgsunstalbe.linuxPackages.kernel.nvidiaPackages.legacy_535);
    #linuxPackages_5_10 = recurseIntoAttrs (linuxPackagesFor pkgs.linux_5_10);
  };

  nvidia.prime = {
    offload = {
      enable = true;
      enableOffloadCmd = true;
    };
    nvidiaBusId = "PCI:1:0:0";
    amdgpuBusId = "PCI:5:0:0";
  };
}
