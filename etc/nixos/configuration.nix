{
  config,
  pkgs,
  lib,
  inputs,
  rust-overlay,
  #nixpkgs-stable-unstable,
  ...
}: let
  system = "x86_64-linux";
  tokyoNightTheme = pkgs.fetchFromGitHub {
    owner = "BennyOe";
    repo = "tokyo-night.yazi";
    rev = "main";
    sha256 = "112r9b7gan3y4shm0dfgbbgnxasi7ywlbk1pksdbpaglkczv0412";
  };
  unstable = import inputs.nixos-unstable {
    inherit system;
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
    inputs.sops-nix.nixosModules.sops
    ./hardware-configuration.nix
    ./modules/desktop.nix
    ./modules/cpu.nix
    ./modules/window_manager.nix
    ./modules/fonts_icons.nix
    ./modules/xray.nix
    ./modules/ssh.nix
    ./modules/yubikey.nix
    inputs.wireguard.nixosModules.default
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
        watchdog = {
          enable = true;
          pingIP = "10.252.1.0";
          interval = 30;
        };
      };
    }
    inputs.surrealdb.nixosModules.default
  ];

  #programs.nvf = {
  #  enable = true;
  #};

  #nixpkgs.overlays = [ (final: prev: ) ];

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
        restartUnits = ["wireguard-setup.service"];
      };
      "wireguard/private_key" = {
        owner = config.users.users.systemd-network.name;
        mode = "0400";
        restartUnits = ["wireguard-setup.service"];
      };
      "wireguard/preshared_key" = {
        owner = config.users.users.systemd-network.name;
        mode = "0400";
        restartUnits = ["wireguard-setup.service"];
      };
      "wireguard/public_key" = {
        owner = config.users.users.systemd-network.name;
        mode = "0400";
        restartUnits = ["wireguard-setup.service"];
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

    # Enable CROOON
    cron = {
      enable = true;
    };

    # for ssd
    fstrim.enable = true;
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
      '';
    };

    blueman.enable = true;
  };
  boot = {
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
  networking = {
    hostName = "nixos"; # Define your hostname.

    # Enable networking
    networkmanager.enable = true;
    hosts = {
      "10.252.1.0" = ["dev.graph-learning.ru" "gitea.dev.graph-learning.ru"];
    };
  };

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
  nix.settings.trusted-users = ["dmitrii"];
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

    act
    unstable.woodpecker-cli

    unstable.nh

    attic-client

    sops

    cargo-hakari

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

    lldb # debugging

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

    papirus-icon-theme

    inputs.surrealdb.packages.${system}.latest

    hub
  ];

  programs.direnv.enable = true;

  system.stateVersion = "24.11";
}
