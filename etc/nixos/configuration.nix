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
  unstable = import inputs.nixos-unstable {
    system = "x86_64-linux";
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "electron-27.3.11"
      ];
    };
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
  boot.kernelModules = ["coretemp" "ideapad-laptop" "ryzen_smu"];

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
  services.devmon.enable = true;
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
        turbo = "never";
        #turbo = "auto";
        enable_thresholds = "true";
        start_threshold = 20;
        stop_threshold = 80;
        ideapad_laptop_conservation_mode = "true";
        scaling_min_freq = 400000;
        scaling_max_freq = 3000000;
      };
      charger = {
        governor = "performance";
        turbo = "never";
        scaling_min_freq = 400000;
        scaling_max_freq = 3800000;
      };
    };
  };
  hardware.cpu.amd.ryzen-smu.enable = true;

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
  # multi-touch gesture recognizer
  services.touchegg.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.dmitrii = {
    isNormalUser = true;
    description = "Dmitrii";
    # Needs groups input and uinput for kanata to work without sudo
    extraGroups = ["networkmanager" "wheel" "dmitrii" "docker" "video" "tty" "libvirtd" "input" "uinput" "plugdev" "dialout"];
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
    nerd-fonts.symbols-only
    nerd-fonts.meslo-lg
    #nerd-fonts.hurmit
    #nerd-fonts.iosevka-term
    #nerd-fonts.monoid
    font-awesome
    freefont_ttf
    corefonts # Times New Roman
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
    #inputs.nixpkgs.legacyPackages.${pkgs.system}.vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    vim
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
    #inputs.nixos-unstable.legacyPackages.${pkgs.system}.surrealdb
    unstable.surrealdb
    inputs.nixos-unstable.legacyPackages.${pkgs.system}.surrealist
    inputs.nixos-unstable.legacyPackages.${pkgs.system}.surrealdb-migrations
    #nerdfonts
    #terminus-nerdfont
    nerd-fonts.symbols-only
    nerd-fonts.meslo-lg
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
    #mplayer # live wallpapers
    inputs.nixos-24-11-stable-xsecurelock.legacyPackages.${pkgs.system}.mplayer

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

    #inputs.nixos-unstable.legacyPackages.${pkgs.system}.obsidian
    unstable.obsidian
    #inputs.nixos-unstable.legacyPackages.${pkgs.system}.logseq
    #inputs.nixpkgs.legacyPackages.${pkgs.system}.logseq

    nix-template

    usbutils
    udiskie
    udisks

    spacedrive

    wakatime

    logisim-evolution
    qucs-s

    nekoray

    lenovo-legion

    yosys
    #unstable.yosys-synlig
    yosys-ghdl
    netlistsvg
    mcy
    sby
    boolector
    btor2tools
    z3

    zotero

    amdctl

    ryzenadj

    syncthing

    pdfannots2json

    openhantek6022

    kicad

    pdfsam-basic

    plantuml-c4

    wgpu-utils

    xclip

    jdk23
    ethtool

    teamspeak3
  ];

  # Because of logseq
  nixpkgs.config.
  permittedInsecurePackages = [
    "electron-27.3.11"
  ];

  programs.direnv.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    withNodeJs = true;
    withPython3 = true;
  };
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = false;
    dedicatedServer.openFirewall = false;
  };

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = "dmitrii";
    group = "dmitrii";
    dataDir = "/home/dmitrii/education";
  };

  # Needs for yubikey
  services.pcscd.enable = true;

  services.v2raya.enable = true;
  # TODO:
  #services.sing-box.enable = true;

  services.playerctld.enable = true; # Media keys

  # services.kanata.enable = true; # keys
  services.interception-tools = {
    enable = true;
  };

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
        SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", RUN+="${pkgs.ryzenadj}/bin/ryzenadj -a 35000 -b 35000 -c 35000 -f 85"
        SUBSYSTEM=="power_supply", ATTR{status}=="Charging", RUN+="${pkgs.ryzenadj}/bin/ryzenadj -a 35000 -b 35000 -c 35000 -f 85"

        # rules for OpenHantek6022 (DSO program) as well as Hankek6022API (python tools)
        ACTION!="add|change", GOTO="openhantek_rules_end"
        SUBSYSTEM!="usb|usbmisc|usb_device", GOTO="openhantek_rules_end"
        ENV{DEVTYPE}!="usb_device", GOTO="openhantek_rules_end"

        # Hantek DSO-6022BE, without FW, with FW
        ATTRS{idVendor}=="04b4", ATTRS{idProduct}=="6022", TAG+="uaccess", TAG+="udev-acl", MODE="660", GROUP="plugdev"
        ATTRS{idVendor}=="04b5", ATTRS{idProduct}=="6022", TAG+="uaccess", TAG+="udev-acl", MODE="660", GROUP="plugdev"

        # Instrustar isds-205b, without FW, with FW
        ATTRS{idVendor}=="d4a2", ATTRS{idProduct}=="5661", TAG+="uaccess", TAG+="udev-acl", MODE="660", GROUP="plugdev"
        ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="1d50", TAG+="uaccess", TAG+="udev-acl", MODE="660", GROUP="plugdev"

        # Hantek DSO-6022BL, without FW, with FW
        ATTRS{idVendor}=="04b4", ATTRS{idProduct}=="602a", TAG+="uaccess", TAG+="udev-acl", MODE="660", GROUP="plugdev"
        ATTRS{idVendor}=="04b5", ATTRS{idProduct}=="602a", TAG+="uaccess", TAG+="udev-acl", MODE="660", GROUP="plugdev"

        # Voltcraft DSO-2020, without FW (becomes DSO-6022BE when FW is uploaded)
        ATTRS{idVendor}=="04b4", ATTRS{idProduct}=="2020", TAG+="uaccess", TAG+="udev-acl", MODE="660", GROUP="plugdev"

        # BUUDAI DDS120, without FW, with FW
        ATTRS{idVendor}=="8102", ATTRS{idProduct}=="8102", TAG+="uaccess", TAG+="udev-acl", MODE="660", GROUP="plugdev"
        ATTRS{idVendor}=="04b5", ATTRS{idProduct}=="0120", TAG+="uaccess", TAG+="udev-acl", MODE="660", GROUP="plugdev"

        # Hantek DSO-6021, without FW, with FW
        ATTRS{idVendor}=="04b4", ATTRS{idProduct}=="6021", TAG+="uaccess", TAG+="udev-acl", MODE="660", GROUP="plugdev"
        ATTRS{idVendor}=="04b5", ATTRS{idProduct}=="6021", TAG+="uaccess", TAG+="udev-acl", MODE="660", GROUP="plugdev"

        # YiXingDianZiKeJi MDSO, without FW, with FW
        ATTRS{idVendor}=="d4a2", ATTRS{idProduct}=="5660", TAG+="uaccess", TAG+="udev-acl", MODE="660", GROUP="plugdev"
        ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="608e", TAG+="uaccess", TAG+="udev-acl", MODE="660", GROUP="plugdev"

        LABEL="openhantek_rules_end"
      '';
    };
  };

  # bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    input = {
      General = {
        UserspaceHID = true;
        Experimental = true;
      };
    };
  };
  services.blueman.enable = true;

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
