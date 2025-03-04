# Apps and Packages for window managers
{
  config,
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    dmenu-rs
    eww
    polybarFull
    feh
    rofi
    dunst

    inputs.nixos-unstable.legacyPackages.${pkgs.system}.xsecurelock # lock

    libnotify

    xorg.xev # get key number/name
    xorg.xrandr # screen
    autorandr # screen

    xss-lock # auto lock?

    xorg.xset
  ];
  services.xserver = {
    # Enable the X11 windowing system.
    # You can disable this if you're only using the Wayland session.
    enable = true;

    windowManager.leftwm.enable = true;

    displayManager = with pkgs; {
      sessionCommands = ''
        # Trigger xlock on suspend.
        ${xorg.xset}/bin/xset s 300 5
        ${xorg.xset}/bin/xset -dpms
        ${xss-lock}/bin/xss-lock -l  -- ${xsecurelock}/bin/xsecurelock &
      '';
      lightdm.enable = true;
    };

    # Enable the KDE Plasma Desktop Environment.
    #services.displayManager.sddm.enable = true;
    #services.desktopManager.plasma6.enable = true;
    #services.displayManager.defaultSession = "plasmax11";

    # Configure keymas

    xkb = {
      layout = "us,ru";
      variant = "";
      options = "grp:win_space_toggle";
    };

    # Firmwares updates
    # services.fwupd.enable = true;

    videoDrivers = [
      "amdgpu"
      #"modesetting"

      "nvidia"

      #"displaylink"
      #"nvidia" "amdgpu-pro"
    ];
  };

  systemd.services.autorandr = {
    enable = true;
    description = "autorandr execution hook";
    after = ["sleep.target"];
    startLimitBurst = 1;
    startLimitIntervalSec = 5;
    wantedBy = ["sleep.target"];
    serviceConfig = {
      ExecStart = ''${pkgs.autorandr}/bin/autorandr --batch --change --default default'';
      Type = "oneshot";
      RemainAfterExit = "false";
    };
  };
}
