# Apps and Packages for desktop
{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    telegram-desktop
  ];
}
