{
  config,
  pkgs,
  lib,
  inputs,
  rust-overlay,
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
    overlays = [
      (import ../../nix/overlays/todo-backend.nix)
    ];
  };
in {
  imports = [
    # Include the results of the hardware scan.
    inputs.sops-nix.nixosModules.sops
    ./hardware-configuration.nix
    ./modules/desktop.nix
    ./modules/window_manager.nix
    ./modules/fonts_icons.nix
    ./modules/xray.nix
    ./modules/ssh.nix
    ./modules/yubikey.nix
    ../../nix/modules/wireguard.nix
    {
      services.wireguard = {
        enable = true;
        ips = "10.252.1.1/24";
        privateKeyFile = config.sops.secrets."wireguard/private_key".path;
        peers = [
          {
            publicKeyFile = config.sops.secrets."wireguard/public_key".path;
            presharedKeyFile = config.sops.secrets."wireguard/preshared_key".path;
            allowedIPs = "10.252.1.0/24";
            endpointFile = config.sops.secrets."wireguard/wireguard_ip".path;
            endpointPort = 51820;
          }
        ];
      };
    }
    #../../nix/modules/nvf-configuration.nix
    # ./modules/fpga_hardware.nix
    # ./modules/virtualization.nix
    # ./neovim.nix
    # ./suspend_and_hibernate.nix
    # ./home/dmitrii/shared/dotfiles/etc/nixos/modules/wireguard.nix
  ];

  #programs.nvf = {
  #  enable = true;
  #};

  #nixpkgs.overlays = [ (final: prev: ) ];
  nixpkgs.overlays = [
    (import ../../nix/overlays/surrealdb-bin.nix)
  ];

  sops = {
    defaultSopsFile = ./secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    age = {
      sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };
    secrets = {
      "wireguard/wireguard_ip" = {
        owner = config.users.users.systemd-network.name;
        mode = "0400";
      };
      "wireguard/private_key" = {
        owner = config.users.users.systemd-network.name;
        mode = "0400";
      };
      "wireguard/preshared_key" = {
        owner = config.users.users.systemd-network.name;
        mode = "0400";
      };
      "wireguard/public_key" = {
        owner = config.users.users.systemd-network.name;
        mode = "0400";
      };
    };
    #secrets."woodpecker/ip" = {
    #  owner = config.users.users.systemd-network.name;
    #  mode = "0400";
    #};
  };
  services = {
    # For woodpecker-cli
    passSecretService.enable = true;
    gnome.gnome-keyring.enable = true;

    acpid.enable = true; # light control ?

    # Auto mount
    devmon.enable = true;
    gvfs.enable = true;
    udisks2.enable = true;
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
    auto-cpufreq = {
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
          scaling_max_freq = 3500000;
        };
      };
    };

    # Enable CROOON
    cron = {
      enable = true;
    };

    # for ssd
    fstrim.enable = true;
    xserver = {
      # Enable the X11 windowing system.
      # You can disable this if you're only using the Wayland session.
      enable = true;

      windowManager.leftwm.enable = true;

      displayManager = with pkgs; {
        sessionCommands = ''
          # Trigger xlock on suspend.
          ${xorg.xset}/bin/xset s 300 5
          ${xss-lock}/bin/xss-lock -l  -- ${xsecurelock}/bin/xsecurelock &
        '';
        lightdm.enable = true;
      };

      # Enable the KDE Plasma Desktop Environment.
      #services.displayManager.sddm.enable = true;
      #services.desktopManager.plasma6.enable = true;
      #services.displayManager.defaultSession = "plasmax11";

      # Configure keymas

      xkb = {
        layout = "us,ru";
        variant = "";
        options = "grp:win_space_toggle";
      };

      # Firmwares updates
      # services.fwupd.enable = true;

      videoDrivers = [
        "amdgpu"
        #"modesetting"

        "nvidia"

        #"displaylink"
        #"nvidia" "amdgpu-pro"
      ];
    };
    #"modesetting" - FOSS drivers for nvidia
    #services.xserver.displayManager.sessionCommands = ''
    #    ${lib.getBin pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource 2 0
    #'';

    # Enable CUPS to print documents.
    printing.enable = true;
    printing.drivers = [pkgs.hplipWithPlugin];
    avahi.enable = true;

    # run Android apps
    # currently disabled. crushed whole system several times
    #virtualisation.waydroid.enable = true;

    #users.extraUsers.waydroid-desktop.isNormalUser = true;
    #services.cage.user = "waydroid-desktop";
    #services.cage.program = "${pkgs.waydroid}/bin/waydroid show-full-ui";
    #services.cage.enable = true;

    # Enable touchpad support (enabled default in most desktopManager).
    libinput.enable = true;
    # multi-touch gesture recognizer
    touchegg.enable = true;

    logind.extraConfig = ''
      HandlePowerKey=suspend
      IdleAction=suspend
      IdleActionSec=1m
    '';

    #programs.neovim = {
    #  enable = true;
    #  defaultEditor = true;
    #  withNodeJs = true;
    #  withPython3 = true;
    #  package = unstable.neovim;
    #};

    #services.syncthing = {
    #  enable = true;
    #  openDefaultPorts = true;
    #  user = "dmitrii";
    #  group = "dmitrii";
    #  dataDir = "/home/dmitrii/education";
    #};

    v2raya.enable = true;
    # TODO:
    #services.sing-box.enable = true;

    playerctld.enable = true; # Media keys

    # services.kanata.enable = true; # keys
    interception-tools = {
      enable = true;
    };

    udev = {
      packages = [
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
        SUBSYSTEM=="usb", ACTION="add", RUN+="${pkgs.ryzenadj}/bin/ryzenadj -a 35000 -b 35000 -c 35000 -f 85"
      '';
    };

    blueman.enable = true;
  };
  boot = {
    kernelModules = ["coretemp" "ideapad-laptop" "ryzen_smu"];

    kernelParams = ["mem_sleep_default=deep"];
    loader = {
      #systemd.sleep.extraConfig = ''
      #  HibernateDelaySec=30m
      #  SuspendState=mem
      #'';

      # Bootloader.
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;

      # Memtesting of Ram during boot
      systemd-boot.memtest86.enable = true;
    };
  };

  networking.hostName = "nixos"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;
  nix = {
    # Enable flakes
    settings.experimental-features = ["nix-command" "flakes"];

    optimise.automatic = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };
  hardware = {
    # acpi thermal readings??
    acpilight.enable = true;
    cpu.amd.ryzen-smu.enable = true;

    keyboard.qmk.enable = true;

    # bluetooth
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      input = {
        General = {
          UserspaceHID = true;
          Experimental = true;
        };
      };
    };

    ###### GPU tweaks
    # Enable OpenGL
    graphics = {
      enable = true;
      enable32Bit = true;
    };

    nvidia = {
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

    nvidia.prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      nvidiaBusId = "PCI:1:0:0";
      amdgpuBusId = "PCI:5:0:0";
    };
  };

  powerManagement.enable = true;

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
  console.keyMap = "us";
  virtualisation = {
    # - lily58 firmware

    podman = {
      enable = true;
    };
    docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
        daemon.settings = {
          insecure-registries = ["10.252.1.8:5000"];
        };
      };
      package = pkgs.docker;
      autoPrune.enable = true;
      autoPrune.dates = "weekly";
      #extraOptions = ''
      #  --insecure-registry 10.252.1.8:5000
      #'';
      daemon.settings = {
        insecure-registries = ["10.252.1.8:5000"];
      };
    };
    containerd.enable = true;
    containerd.settings = {
      plugins."io.containerd.grpc.v1.cri".registry = {
        config_path = "/etc/containerd/certs.d";
      };
    };
    oci-containers.backend = "podman";
    containers.enable = true;
    containers.registries.insecure = ["10.252.1.8:5000"];
  };
  #        [plugins."io.containerd.grpc.v1.cri".registry]
  #   config_path = "/etc/containerd/certs.d"

  #        server = "https://docker.io"
  #
  #[host."https://registry-1.docker.io"]
  #  capabilities = ["pull", "resolve"]

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.dmitrii = {
    isNormalUser = true;
    description = "Dmitrii";
    # Needs groups input and uinput for kanata to work without sudo
    extraGroups = [
      "dmitrii"
      "networkmanager"
      "wheel"
      "docker"
      "podman"
      "video"
      "tty"
      "libvirtd"
      "input"
      "uinput"
      "plugdev"
      "dialout"
      "xray"
    ];
    uid = 1000;
    #packages = with pkgs; [
    #  # kdePackages.kate
    #  #  thunderbird
    #];
  };
  users.groups.dmitrii.gid = 1000;
  #programs.slock.enable = true;
  #security.setuidPrograms = [ "slock" ];
  programs.light.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

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
  #environment.variables.EDITOR = "nvim";
  programs.neovim.defaultEditor = true;

  # bad idea
  #environment.memoryAllocator.provider = "jemalloc";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #inputs.nixpkgs.legacyPackages.${pkgs.system}.vim
    #colmena.defaultPackage.x86_64-linux
    cri-tools
    dive # look into docker image layers
    podman-tui # status of containers in the terminal
    docker-compose # start group of containers for dev
    #podman-compose # start group of containers for dev

    #vim
    #nixpkgs-stable-unstable.vim
    #vim
    wget
    displaylink
    neofetch
    tmux
    alacritty
    lshw
    unstable.htop
    btop
    gparted
    git
    stow
    gcc14
    rocmPackages.llvm.clang-unwrapped
    unstable.nodejs_22

    surrealdb-bin

    unstable.todo-backend

    act
    unstable.woodpecker-cli

    sops

    cargo-hakari

    #unstable.surrealdb
    #unstable.surrealist
    #unstable.surrealdb-migrations

    #unstable.surrealdb
    #unstable.surrealist
    #unstable.surrealdb-migrations

    #inputs.nixos-unstable.legacyPackages.${pkgs.system}.surrealdb
    #inputs.nixos-unstable.legacyPackages.${pkgs.system}.surrealist
    #inputs.nixos-unstable.legacyPackages.${pkgs.system}.surrealdb-migrations

    hunspell
    hunspellDicts.ru_RU
    hunspellDicts.en_US
    gnumake
    v2raya
    discord
    alejandra
    memtest86plus
    memtester
    busybox
    noisetorch

    # PYTHON
    python312
    python312Packages.pip
    python312Packages.ansible-core
    python312Packages.pipx
    python312Packages.pynvim
    python312Packages.virtualenv
    python312Packages.pandas
    python312Packages.numpy
    python312Packages.matplotlib
    python312Packages.scipy
    pandoc

    cht-sh

    go

    age
    ssh-to-age

    mtr

    sox

    appimage-run

    ripgrep

    xkb-switch

    networkmanager
    networkmanager_dmenu

    qalculate-gtk

    light # set backlight
    #xorg.xbacklight

    ueberzugpp # Display images in alacritty

    #komorebi
    xwinwrap

    ffmpeg-full

    imagemagick

    unrar-wrapper
    p7zip
    _7zz # rar archives

    lazygit

    xorg.xdpyinfo # dpi info for scaling
    # TODO

    unstable.clang-tools

    arandr

    xorg.xinit

    hplipWithPlugin # hp printer

    getent
    auto-cpufreq

    #rustup
    #unstable.cargo
    #unstable.rustc
    #unstable.rust-analyzer
    #unstable.rustfmt
    #unstable.clippy

    mdbook

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

    nix-template

    usbutils
    udiskie
    udisks

    spacedrive

    wakatime

    nekoray

    lenovo-legion

    zotero

    amdctl

    ryzenadj

    pdfannots2json

    pdfsam-basic

    plantuml-c4

    wgpu-utils

    xclip

    jdk23
    ethtool

    teamspeak3

    nextcloud-client

    ocrmypdf

    lldb

    terraform
    opentofu

    nixos-generators

    nil

    git-crypt
    gnupg
    pinentry-curses

    papirus-icon-theme
  ];

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
  };

  programs.direnv.enable = true;

  programs.ssh.startAgent = true;
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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  #system.stateVersion = "24.05"; # Did you read the comment?
  system.stateVersion = "24.11"; # Did you read the comment?
}
