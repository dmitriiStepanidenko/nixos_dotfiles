# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  inputs,
  #nixpkgs-stable-unstable,
  ...
}: let
  tokyoNightTheme = pkgs.fetchFromGitHub {
    owner = "BennyOe";
    repo = "tokyo-night.yazi";
    rev = "main";
    sha256 = "112r9b7gan3y4shm0dfgbbgnxasi7ywlbk1pksdbpaglkczv0412";
  };
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    #./neovim.nix
    #./suspend_and_hibernate.nix
    #./home/dmitrii/shared/dotfiles/etc/nixos/modules/wireguard.nix
    #./modules/wireguard.nix
  ];

  # Cuz Nvidia. I need 535 version
  #boot.kernelPackages = inputs.nixpkgsunstable.linuxPackages_latest;
  #boot.kernelPackages = pkgs.unstable.nixpkgsunstable.linuxPackages_latest;
  #boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.kernelParams = ["mem_sleep_default=deep"];
  #systemd.sleep.extraConfig = ''
  #  HibernateDelaySec=30m
  #  SuspendState=mem
  #'';

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Memtesting of Ram during boot
  boot.loader.systemd-boot.memtest86.enable = true;

  # Because Nvivia?
  #boot.kernelParams = [ "module_blacklist=amdgpu" ];

  #boot.initrd.kernelModules = ["amdgpu"];
  #boot.extraModulePackages = [config.boot.kernelPackages.nvidia_x11];
  #boot.kernelPackages = [];

  networking.hostName = "nixos"; # Define your hostname.

  #networking.wireless.enable = true; # Enables wireless support via wpa_supplicant.
  #networking.wireless.iwd.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable flakes
  nix.settings.experimental-features = ["nix-command" "flakes"];

  services.acpid.enable = true; # acpi thermal readings??
  hardware.acpilight.enable = true; # light control ?

  # Auto mount
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  powerManagement.enable = true;
  # Power management
  #powerManagement.powertop.enable = true; # This thing make my usb devices "laggy" at connection
  #services.thermald.enable = true;
  #services.tlp = {
  #  enable = true;
  #  settings = {
  #    CPU_SCALING_GOVERNOR_ON_AC = "performance";
  #    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

  #    CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
  #    CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

  #    CPU_MIN_PERF_ON_AC = 0;
  #    CPU_MAX_PERF_ON_AC = 90;
  #    CPU_MIN_PERF_ON_BAT = 0;
  #    CPU_MAX_PERF_ON_BAT = 40;

  #    #Optional helps save long term battery health
  #    START_CHARGE_THRESH_BAT0 = 40; # 40 and bellow it starts to charge
  #    STOP_CHARGE_THRESH_BAT0 = 80; # 80 and above it stops charging
  #  };
  #};

  # THis piece of shit does not work!
  services.auto-cpufreq = {
    enable = true;
    settings = {
      battery = {
        governor = "powersave";
        #turbo = "never";
        turbo = "auto";
        enable_thresholds = "true";
        start_threshold = 20;
        stop_threshold = 80;
        ideapad_laptop_conservation_mode = "true";
      };
      charger = {
        governor = "performance";
        turbo = "auto";
      };
    };
  };

  # Enable CROOON
  services.cron = {
    enable = true;
  };

  # Set your time zone.
  time.timeZone = "Europe/Moscow";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };

  # for ssd
  services.fstrim.enable = true;

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  services.xserver.windowManager.leftwm.enable = true;

  services.xserver = {
    displayManager = with pkgs; {
      sessionCommands = ''
        # Trigger xlock on suspend.
        ${xorg.xset}/bin/xset s 300 5
        ${xss-lock}/bin/xss-lock -l  -- ${xsecurelock}/bin/xsecurelock &
      '';
      lightdm.enable = true;
    };
  };

  # Enable the KDE Plasma Desktop Environment.
  #services.displayManager.sddm.enable = true;
  #services.desktopManager.plasma6.enable = true;
  #services.displayManager.defaultSession = "plasmax11";

  # Configure keymas
  services.xserver = {
    xkb = {
      layout = "us,ru";
      variant = "";
      options = "grp:win_space_toggle";
    };
  };
  console.keyMap = "us";

  # Firmwares updates
  # services.fwupd.enable = true;

  services.xserver.videoDrivers = [
    "amdgpu"
    #"modesetting"

    "nvidia"

    #"displaylink"
    #"nvidia" "amdgpu-pro"
  ];
  #"modesetting" - FOSS drivers for nvidia
  #services.xserver.displayManager.sessionCommands = ''
  #    ${lib.getBin pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource 2 0
  #'';

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [pkgs.hplipWithPlugin];
  services.avahi.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  hardware.keyboard.qmk.enable = true; # - lily58 firmware

  virtualisation.docker.enable = true;

  # run Android apps
  # currently disabled. crushed whole system several times
  #virtualisation.waydroid.enable = true;

  #users.extraUsers.waydroid-desktop.isNormalUser = true;
  #services.cage.user = "waydroid-desktop";
  #services.cage.program = "${pkgs.waydroid}/bin/waydroid show-full-ui";
  #services.cage.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.dmitrii = {
    isNormalUser = true;
    description = "Dmitrii";
    # Needs groups input and uinput for kanata to work without sudo
    extraGroups = ["networkmanager" "wheel" "dmitrii" "docker" "video" "tty" "libvirtd" "input" "uinput"];
    uid = 1000;
    #packages = with pkgs; [
    #  # kdePackages.kate
    #  #  thunderbird
    #];
  };
  users.groups.dmitrii.gid = 1000;

  # Virtual Box
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = ["dmitrii"];
  virtualisation.virtualbox.host.enableExtensionPack = true;
  #virtualisation.virtualbox.guest.enable = true;
  #virtualisation.virtualbox.guest.draganddrop = true;

  # Libvirt
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  # Install firefox.
  programs.firefox.enable = true;

  services.logind.extraConfig = ''
    HandlePowerKey=suspend
    IdleAction=suspend
    IdleActionSec=1m
  '';
  #programs.slock.enable = true;
  #security.setuidPrograms = [ "slock" ];
  programs.light.enable = true;

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

  # Needs for Telegram popup windows
  qt = {
    enable = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  fonts.enableDefaultPackages = true;
  fonts.packages = with pkgs; [
    fira-code
    fira-code-symbols
    nerdfonts
  ];

  programs.noisetorch.enable = true;

  # Default browser
  xdg.mime.defaultApplications = {
    "text/html" = "firefox.desktop";
    "application/pdf" = "firefox.desktop";
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
    "x-scheme-handler/about" = "firefox.desktop";
    "x-scheme-handler/unknown" = "firefox.desktop";
    "inode/directory" = "yazi.desktop";
  };

  programs.yazi = {
    enable = true;
    flavors = {
      tokyo-night = tokyoNightTheme;
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    inputs.nixpkgs.legacyPackages.${pkgs.system}.vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #nixpkgs-stable-unstable.vim
    #vim
    wget
    #neovim
    displaylink
    neofetch
    tmux
    alacritty
    yubioath-flutter
    lshw
    htop
    gparted
    enpass
    git
    stow
    gcc14
    rocmPackages.llvm.clang-unwrapped
    nodejs_22
    telegram-desktop
    #inputs.nixpkgs-stable-unstable.legacyPackages.${pkgs.system}.surrealdb
    #inputs.nixpkgs-stable-unstable.legacyPackages.${pkgs.system}.surrealdb
    surrealdb
    surrealist
    surrealdb-migrations
    nerdfonts
    terminus-nerdfont
    libreoffice-qt
    hunspell
    hunspellDicts.ru_RU
    hunspellDicts.en_US
    gnumake
    v2raya
    discord
    alejandra
    libnotify
    memtest86plus
    memtester
    anki-bin
    google-chrome
    chromium
    busybox
    wireshark
    noisetorch

    # PYTHON
    python312
    python312Packages.pip
    python312Packages.ansible-core
    python312Packages.pipx
    python312Packages.pynvim

    obsidian

    cht-sh

    age
    ssh-to-age

    mtr

    sox

    ledger-live-desktop

    appimage-run

    ripgrep

    dmenu-rs
    eww
    polybarFull
    feh
    rofi
    dunst

    xkb-switch

    networkmanager
    networkmanager_dmenu

    gparted
    qalculate-gtk
    flameshot # screenshots

    vlc # videos
    mpv
    mplayer # live wallpapers

    geany # text editor

    xsecurelock # lock

    light # set backlight
    #xorg.xbacklight

    xorg.xev # get key number/name
    xorg.xrandr # screen
    autorandr # screen

    xss-lock # auto lock?

    xorg.xset

    ueberzugpp # Display images in alacritty

    #komorebi
    xwinwrap

    ffmpeg-full

    imagemagick

    unrar-wrapper
    p7zip
    _7zz # rar archives

    lazygit

    gtkwave
    verilog # icarus verilog
    verilator

    xorg.xdpyinfo # dpi info for scaling
    # TODO

    ghdl

    logisim-evolution

    systemc

    clang-tools

    pavucontrol # gui for sound
    arandr

    xorg.xinit

    hplipWithPlugin # hp printer

    getent
    auto-cpufreq

    #rustup
    cargo
    rustc
    rust-analyzer
    rustfmt
    clippy

    playerctl # Media keys: Play/Pause / etc

    # cmake # needs for cargo-semver-checks
    cargo-semver-checks

    kanata # for remapping of keys

    xorg.xbacklight

    lm_sensors # reding hardware temperature sensors

    # Undervolting (for Intel :(  ) !
    undervolt
    s-tui
    stress
    # Undervolting !

    acpi

    dmidecode

    vhdl-ls

    #nvtopPackages.nvidia
    #nvtopPackages.amd
    nvtopPackages.full

    #waydroid
    graphviz

    via # for lily58. Change layouts

    luajitPackages.magick

    picom

    obsidian
    #logseq

    nix-template

    usbutils
    udiskie
    udisks
  ];

  programs.direnv.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    withNodeJs = true;
    withPython3 = true;
    #extraLuaPackages = ps: [ps.magick];
    #package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
  };
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = false;
    dedicatedServer.openFirewall = false;
  };

  # Needs for yubikey
  services.pcscd.enable = true;

  services.v2raya.enable = true;
  # TODO:
  #services.sing-box.enable = true;

  services.playerctld.enable = true; # Media keys

  #services.kanata.enable = true; # keys

  # For ledger
  hardware.ledger.enable = true;
  services = {
    udev = {
      packages = with pkgs; [
        ledger-udev-rules
        pkgs.via
      ];
      extraRules = ''
        ACTION=="change", SUBSYSTEM=="drm", RUN+="${pkgs.systemd}/bin/systemctl start --no-block autorandr.service"
        SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="[0-2]", RUN+="${pkgs.systemd}/bin/systemctl hybrid-sleep"
        SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="[5-10]", RUN+="${pkgs.libnotify}/bin/notify-send Battery EXTREMELY Low"
        SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="[10-15]", RUN+="${pkgs.libnotify}/bin/notify-send Battery Low"
        KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
        SUBSYSTEM=="backlight", ACTION=="add", KERNEL=="acpi_video0", ATTR{brightness}="8"
      '';
    };
  };

  # bluetooth
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = false; # powers up the default Bluetooth controller on bo

  ###### GPU tweaks
  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = true;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = true;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = true;

    forceFullCompositionPipeline = false;

    # Enable the Nvidia settings menu,
    # accessible via `nviia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.

    # downgrade to 535 because: https://forums.developer.nvidia.com/t/series-550-freezes-laptop/284772/214
    #package = config.boot.kernelPackages.nvidiaPackages.legacy_535;
    #package = config.boot.kernelPackages.nvidiaPackages.beta;
    package = config.boot.kernelPackages.nvidiaPackages.latest;

    #package = (inputs.nixpkgsunstable.linuxPackagesFor config.boot.kernelPackages.kernel).nvidiaPackages.legacy_535;
    #package = (linuxPackagesFor inputs.nixpkgsunstalbe.linuxPackages.kernel.nvidiaPackages.legacy_535);
    #linuxPackages_5_10 = recurseIntoAttrs (linuxPackagesFor pkgs.linux_5_10);
  };

  hardware.nvidia.prime = {
    offload = {
      enable = true;
      enableOffloadCmd = true;
    };
    nvidiaBusId = "PCI:1:0:0";
    amdgpuBusId = "PCI:5:0:0";
  };
  ###### GPU tweaks end

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  #system.stateVersion = "24.05"; # Did you read the comment?
  system.stateVersion = "24.11"; # Did you read the comment?
}
