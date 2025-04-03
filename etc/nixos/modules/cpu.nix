{
  config,
  pkgs,
  inputs,
  ...
}: let
in {
  boot = {
    blacklistedKernelModules = ["amd_pstate_init"];
    kernelParams = ["amd_pstate.enable=0"];
    kernelModules = ["coretemp" "ideapad-laptop" "ryzen_smu"];
  };
  hardware.cpu.amd.ryzen-smu.enable = true;
  #services.udev.extraRules = ''
  #  SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", RUN+="${pkgs.ryzenadj}/bin/ryzenadj -a 35000 -b 35000 -c 35000 -f 85 --apu-skin-temp=85"
  #  SUBSYSTEM=="power_supply", ATTR{status}=="Charging", RUN+="${pkgs.ryzenadj}/bin/ryzenadj -a 35000 -b 35000 -c 35000 -f 85 --apu-skin-temp=85"
  #  SUBSYSTEM=="usb", ACTION="add", RUN+="${pkgs.ryzenadj}/bin/ryzenadj -a 35000 -b 35000 -c 35000 -f 85 --apu-skin-temp=85"
  #'';

  nixpkgs.overlays = [
    (_final: _prev: {
      inherit (inputs.nixos-unstable.legacyPackages.${pkgs.system}) auto-cpufreq;
    })
  ];

  services.auto-cpufreq = {
    enable = true;
    settings = {
      battery = {
        governor = "powersave";
        turbo = "never";
        #turbo = "auto";
        enable_thresholds = "true";
        start_threshold = 20;
        stop_threshold = 80;
        ideapad_laptop_conservation_mode = "true";
        scaling_min_freq = 400000;
        scaling_max_freq = 3000000;
      };
      charger = {
        governor = "performance";
        turbo = "auto";
        start_threshold = 20;
        stop_threshold = 80;
        ideapad_laptop_conservation_mode = "true";
      };
    };
  };
  environment.systemPackages = [pkgs.auto-cpufreq pkgs.ryzenadj];
}
