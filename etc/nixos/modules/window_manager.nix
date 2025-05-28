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
  };
in {
  environment.systemPackages = with pkgs; [
    dmenu-rs
    eww
    polybarFull
    feh
    rofi
    dunst

    #inputs.nixos-unstable.legacyPackages.${pkgs.system}.xsecurelock # lock

    libnotify

    xorg.xev # get key number/name
    xorg.xrandr # screen
    autorandr # screen
    arandr

    xorg.xdpyinfo # dpi info for scaling
    xorg.xinit
    xorg.xbacklight

    xss-lock # auto lock?

    xorg.xset
    i3lock-fancy

    inputs.nixos-unstable.legacyPackages.${pkgs.system}.leftwm

    cosmic-applets.cosmic-ext-applet-privacy-indicator

    libxkbcommon # for cosmic de applets
  ];
  #programs.i3lock.enable = true;

  services.displayManager.cosmic-greeter.enable = true;
  services.desktopManager.cosmic.enable = true;

  services.xserver = {
    # Enable the X11 windowing system.
    # You can disable this if you're only using the Wayland session.
    enable = true;
    desktopManager.xfce.enable = true;
    #xautolock = {
    #  enable = true;
    #  time = 10;
    #  locker = "${pkgs.i3lock-fancy}/bin/i3lock-fancy";
    #};

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

    #displayManager = with pkgs; {
    #  #sessionCommands = ''
    #  #  # Trigger xlock on suspend.
    #  #  ${xorg.xset}/bin/xset s 300 5
    #  #  ${xorg.xset}/bin/xset -dpms
    #  #'';
    #  #lightdm.enable = true;
    #  gdm.enable = true;
    #  gdm.wayland = false;
    #  startx.enable = true;
    #};
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
