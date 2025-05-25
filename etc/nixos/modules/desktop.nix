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

    unstable.telegram-desktop
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

    #inputs.nixos-unstable.legacyPackages.${pkgs.system}.obsidian
    unstable.obsidian
    #inputs.nixos-unstable.legacyPackages.${pkgs.system}.logseq
    #inputs.nixpkgs.legacyPackages.${pkgs.system}.logseq

    ledger-live-desktop

    gpu-screen-recorder # CLI
    gpu-screen-recorder-gtk # GUI

    obs-studio

    unstable.rustdesk-flutter

    waydroid
    waydroid-helper
  ];
  virtualisation.waydroid.enable = true;
  xdg = {
    # Default browser
    mime.defaultApplications = {
      "text/html" = "firefox.desktop";
      "application/pdf" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";
      "inode/directory" = "yazi.desktop";
    };
    #portal = {
    #  enable = false;
    #  extraPortals = [
    #    pkgs.xdg-desktop-portal-cosmic
    #    pkgs.xdg-desktop-portal-gnome
    #  ];
    #  config.common.default = ["cosmic"];
    #  xdgOpenUsePortal = true;
    #};
  };

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
  programs.firefox.enable = true;

  # Enable sound with pipewire.
  security.rtkit.enable = true;
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
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
