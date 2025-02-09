# Apps and Packages for desktop
{
  config,
  pkgs,
  inputs,
  ...
}: {
  # Needs for Telegram popup windows
  qt = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    telegram-desktop
    enpass
    libreoffice-qt

    wireshark

    anki-bin
    google-chrome
    chromium

    gparted

    geany # text editor
    flameshot # screenshots

    vlc # videos
    mpv
    #mplayer # live wallpapers
    inputs.nixos-24-11-stable-xsecurelock.legacyPackages.${pkgs.system}.mplayer
  ];
}
