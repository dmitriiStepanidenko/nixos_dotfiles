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

    #inputs.nixos-unstable.legacyPackages.${pkgs.system}.obsidian
    unstable.obsidian
    #inputs.nixos-unstable.legacyPackages.${pkgs.system}.logseq
    #inputs.nixpkgs.legacyPackages.${pkgs.system}.logseq
  ];

  # Because of logseq
  nixpkgs.config.
  permittedInsecurePackages = [
    "electron-27.3.11"
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = false;
    dedicatedServer.openFirewall = false;
  };

  # Install firefox.
  programs.firefox.enable = true;
}
