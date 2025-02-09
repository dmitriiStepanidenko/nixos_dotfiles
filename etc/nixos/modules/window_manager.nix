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
  ];
}
