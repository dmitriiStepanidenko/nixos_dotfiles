# Apps and Packages for window managers
{
  config,
  pkgs,
  inputs,
  ...
}: let
  cosmic-applets = {
    cosmic-ext-applet-privacy-indicator =
      pkgs.callPackage
      ../../../nix/packages/cosmic-ext-applet-privacy-indicator.nix
      {};
    cosmic-ext-applet-system-monitor =
      pkgs.callPackage
      ../../../nix/packages/cosmic-ext-applet-system-monitor.nix
      {};
  };
in {
  imports = [
    ../../../nix/services/wayland-display-manager-enabler.nix
  ];
  environment.systemPackages = with pkgs; [
    dmenu-rs
    eww
    polybarFull
    feh
    rofi
    dunst

    #inputs.nixos-unstable.legacyPackages.${pkgs.system}.xsecurelock # lock

    xorg.xev # get key number/name
    xorg.xrandr # screen
    autorandr # screen
    arandr

    wlr-randr

    xorg.xdpyinfo # dpi info for scaling
    xorg.xinit
    xorg.xbacklight

    xss-lock # auto lock?

    xorg.xset
    i3lock-fancy

    inputs.nixos-unstable.legacyPackages.${pkgs.system}.leftwm

    cosmic-applets.cosmic-ext-applet-privacy-indicator
    cosmic-applets.cosmic-ext-applet-system-monitor

    libxkbcommon # for cosmic de applets
    wayland

    wofi # wayland launcher for hyperland

    wl-clipboard-rs

    kdePackages.kdenlive

    (
      pkgs.waybar.overrideAttrs (oldAttrs: {
        mesonFlags = oldAttrs.mesonFlags ++ ["-Dexperimental=true"];
      })
    )

    #mako
  ];
  #programs.i3lock.enable = true;

  #services.displayManager.cosmic-greeter.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  services.desktopManager.cosmic.enable = true;
  #  #services.desktopManager.xfce.enable = true;
  services.desktopManager.plasma6.enable = true;

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages."${pkgs.system}".hyprland;
    xwayland.enable = true;
  };
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [
    #pkgs.xdg-desktop-portal-hyprland
    pkgs.xdg-desktop-portal-gtk
  ];

  environment.sessionVariables = {
    #If your cursor becomes invisible
    #WLR_NO_HARDWARE_CURSORS = "1";
    #Hint electron apps to use wayland
    NIXOS_OZONE_WL = "1";
  };

  services.xserver = {
    # Enable the X11 windowing system.
    # You can disable this if you're only using the Wayland session.
    enable = true;
    #desktopManager.xfce.enable = true;
    #xautolock = {
    #  enable = true;
    #  time = 10;
    #  locker = "${pkgs.i3lock-fancy}/bin/i3lock-fancy";
    #};
    autorun = false;

    windowManager = {
      leftwm.enable = true;
      #session = pkgs.lib.singleton {
      #  name = "leftwm";
      #  start = ''
      #    ${inputs.nixos-unstable.legacyPackages.${pkgs.system}.leftwm}/bin/leftwm &
      #    waitPID=$!
      #  '';
      #};
    };

    displayManager = with pkgs; {
      #sessionCommands = ''
      #  # Trigger xlock on suspend.
      #  ${xorg.xset}/bin/xset s 300 5
      #  ${xorg.xset}/bin/xset -dpms
      #'';
      #lightdm.greeter.enable = true;
      #gdm.enable = true;
      #gdm.wayland = false;
      startx.enable = true;
    };
    #${xss-lock}/bin/xss-lock -l  -- ${i3lock}/bin/xsecurelock i3lock &

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
  };

  # Enable the service
  services.display-manager-enabler = {
    enable = false;
    user = "dmitrii";
  };

  systemd.services.autorandr = {
    enable = true;
    description = "autorandr execution hook";
    after = ["sleep.target"];
    startLimitBurst = 1;
    startLimitIntervalSec = 5;
    wantedBy = ["sleep.target"];

    # Add a condition to check for X Server
    unitConfig = {
      ConditionEnvironment = "DISPLAY"; # Only run if DISPLAY is set
      ConditionPathExists = "/tmp/.X11-unix"; # Check for X11 socket directory
    };

    serviceConfig = {
      ExecStart = ''${pkgs.autorandr}/bin/autorandr --batch --change --default default'';
      Type = "oneshot";
      RemainAfterExit = "false";

      # Make it run in the user's session environment
      User = "dmitrii"; # Replace with your username
      Environment = "DISPLAY=:0";
    };
  };
}
