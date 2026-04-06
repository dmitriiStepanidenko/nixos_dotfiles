# Apps and Packages for desktop
{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
  unstable = import inputs.nixos-unstable {
    system = "x86_64-linux";
    config = {
      allowUnfree = true;
    };
  };

  proxyString = "127.0.0.1:10800";
  caffeine-with-indicator = pkgs.caffeine-ng.overrideAttrs (oldAttrs: {
    buildInputs =
      oldAttrs.buildInputs
      ++ [
        pkgs.libappindicator-gtk3

        pkgs.gnomeExtensions.appindicator
      ];
    nativeBuildInputs =
      oldAttrs.nativeBuildInputs
      ++ [
        pkgs.libappindicator-gtk3
        pkgs.gnomeExtensions.appindicator
      ];
  });
in {
  # Needs for Telegram popup windows
  qt = {
    enable = true;
  };

  environment.systemPackages = with pkgs; let
    element-proxied = pkgs.symlinkJoin {
      name = "element-desktop-proxied";
      paths = [unstable.element-desktop];
      buildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/element-desktop \
          --add-flags "--proxy-server=http://${proxyString}" \
          --set HTTP_PROXY "http://${proxyString}" \
          --set HTTPS_PROXY "http://${proxyString}"
        mv $out/bin/element-desktop $out/bin/element-desktop-proxied
      '';
    };
    fluffychat-proxied = pkgs.symlinkJoin {
      name = "element-desktop-proxied";
      paths = [unstable.fluffychat];
      buildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/fluffychat \
          --set HTTP_PROXY "http://${proxyString}" \
          --set HTTPS_PROXY "http://${proxyString}"
        mv $out/bin/fluffychat $out/bin/fluffychat-proxied
      '';
    };
    kdenlive-nvidia = pkgs.symlinkJoin {
      name = "kdenlive-nvidia";
      paths = [
        kdePackages.kdenlive
      ];
      buildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/kdenlive \
          --set HTTP_PROXY "http://${proxyString}" \
          --set HTTPS_PROXY "http://${proxyString}" \
          --set __NV_PRIME_RENDER_OFFLOAD 1 \
          --set __NV_PRIME_RENDER_OFFLOAD_PROVIDER "NVIDIA-G0" \
          --set __GLX_VENDOR_LIBRARY_NAME "nvidia" \
          --set __VK_LAYER_NV_optimus "NVIDIA_only" \
          --prefix LD_LIBRARY_PATH : ${stdenv.cc.cc.lib}/lib
        mv $out/bin/kdenlive $out/bin/kdenlive_nvidia

        wrapProgram $out/bin/kdenlive_render \
          --set HTTP_PROXY "http://${proxyString}" \
          --set HTTPS_PROXY "http://${proxyString}" \
          --set __NV_PRIME_RENDER_OFFLOAD 1 \
          --set __NV_PRIME_RENDER_OFFLOAD_PROVIDER "NVIDIA-G0" \
          --set __GLX_VENDOR_LIBRARY_NAME "nvidia" \
          --set __VK_LAYER_NV_optimus "NVIDIA_only" \
          --prefix LD_LIBRARY_PATH : ${stdenv.cc.cc.lib}/lib
        mv $out/bin/kdenlive_render $out/bin/kdenlive_render_nvidia
      '';
    };
    #cudaPkgs = import inputs.nixpkgs {
    #  config = {
    #    allowUnfree = true;
    #    cudaSupport = true;
    #  };
    #};
  in [
    pavucontrol # gui for sound

    libnotify

    unstable.telegram-desktop
    unstable.enpass
    libreoffice-qt

    pulseaudioFull

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
    element-proxied
    unstable.element-call
    unstable.halloy
    unstable.fluffychat
    fluffychat-proxied

    kwalletcli
    kdePackages.kwallet

    #caffeine-ng
    caffeine-with-indicator
    gnomeExtensions.appindicator
    libappindicator

    handbrake

    blender

    kdePackages.kdenlive
    kdenlive-nvidia
    python312Packages.srt
    python312Packages.torch
    (python3.withPackages (python-pkgs:
      with python-pkgs; [
        pip
        srt
        torch
        openai-whisper
        websockets
        #torchWithCuda
      ]))
    #cudaPackages.cudatoolkit

    slurp # cursor position

    claude-code
    # this needs for statusline to work
    jq

    aider-chat-full

    unstable.opencode
    inputs.daniel-lightrag-mcp.packages.${system}.default
  ];
  programs.ydotool.enable = true;
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
    package = pkgs.firefox-bin;
    #package = pkgs.wrapFirefox (pkgs.firefox-unwrapped.override {pipewireSupport = true;}) {};
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

  # Redshift part
  sops.secrets."location/latitude" = {
    sopsFile = ./../secrets/not-so-secret-secrets.yaml;
  };

  sops.secrets."location/longitude" = {
    sopsFile = ./../secrets/not-so-secret-secrets.yaml;
  };
  sops.templates."redshift.conf" = {
    content = ''
      [redshift]
      location-provider=manual

      [manual]
      lat=${config.sops.placeholder."location/latitude"}
      lon=${config.sops.placeholder."location/longitude"}
    '';
    owner = config.users.users.dmitrii.name;
  };

  services.redshift = {
    enable = false; # doesn't work on external monitors anyway
    brightness = {
      # Note the string values below.
      day = "1";
      night = "0.2";
    };
    temperature = {
      day = 5500;
      night = 3700;
    };
    # Don't use location.provider/latitude/longitude
    # Instead override the service to use your template
  };

  systemd.user.services.redshift.serviceConfig.ExecStart = lib.mkForce "${pkgs.redshift}/bin/redshift -c ${config.sops.templates."redshift.conf".path}";
}
