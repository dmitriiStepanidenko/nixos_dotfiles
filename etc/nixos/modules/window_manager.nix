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

    xsecurelock # lock

    libnotify

    xorg.xev # get key number/name
    xorg.xrandr # screen
    autorandr # screen

    xss-lock # auto lock?

    xorg.xset
  ];

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
