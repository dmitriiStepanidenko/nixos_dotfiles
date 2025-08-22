# Apps and Packages for desktop
{
  config,
  pkgs,
  inputs,
  ...
}: let
  unstable = import inputs.nixos-unstable {
    system = "x86_64-linux";
    config = {
      allowUnfree = true;
    };
  };
in {
  # Needs for Telegram popup windows
  qt = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    pavucontrol # gui for sound

    libnotify

    unstable.telegram-desktop
    enpass
    libreoffice-qt

    wireshark

    anki-bin
    google-chrome
    #chromium

    gparted

    geany # text editor
    flameshot # screenshots

    vlc # videos
    mpv
    #mplayer # live wallpapers

    #inputs.nixos-unstable.legacyPackages.${pkgs.system}.obsidian
    unstable.obsidian
    #inputs.nixos-unstable.legacyPackages.${pkgs.system}.logseq
    #inputs.nixpkgs.legacyPackages.${pkgs.system}.logseq

    ledger-live-desktop

    gpu-screen-recorder # CLI
    gpu-screen-recorder-gtk # GUI

    unstable.rustdesk-flutter

    waydroid
    waydroid-helper

    revolt-desktop

    easyeffects

    brave

    nautilus
    xarchiver

    unstable.element-desktop
    unstable.element-call
    unstable.halloy

    kwalletcli
    kdePackages.kwallet
  ];
  programs.noisetorch.enable = true;
  virtualisation.waydroid.enable = true;

  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;
  };
  # Setting up in home-manager
  #xdg = {
  #  # Default browser
  #  mime.defaultApplications = {
  #    "text/html" = "firefox.desktop";
  #    "application/pdf" = "firefox.desktop";
  #    "x-scheme-handler/http" = "firefox.desktop";
  #    "x-scheme-handler/https" = "firefox.desktop";
  #    "x-scheme-handler/about" = "firefox.desktop";
  #    "x-scheme-handler/unknown" = "firefox.desktop";
  #    "inode/directory" = "yazi.desktop";
  #  };
  #    ##portal = {
  #    ##  enable = true;
  #    ##  extraPortals = with pkgs; [
  #    ##    xdg-desktop-portal-wlr
  #    ##    xdg-desktop-portal-gtk
  #    ##  ];
  #    ##};
  #  #portal = {
  #  #  enable = false;
  #  #  extraPortals = [
  #  #    pkgs.xdg-desktop-portal-cosmic
  #  #    pkgs.xdg-desktop-portal-gnome
  #  #  ];
  #  #  config.common.default = ["cosmic"];
  #  #  xdgOpenUsePortal = true;
  #  #};
  #};

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = false;
    dedicatedServer.openFirewall = false;
    package = unstable.steam;
  };

  programs.localsend = {
    enable = true;
  };

  # Install firefox.
  programs.firefox = {
    enable = true;
    package = pkgs.wrapFirefox (pkgs.firefox-unwrapped.override {pipewireSupport = true;}) {};
  };

  # Enable sound with pipewire.
  security.rtkit.enable = true;
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # For ledger
  hardware.ledger.enable = true;
  services = {
    udev = {
      packages = with pkgs; [
        ledger-udev-rules
      ];
    };
  };
}
