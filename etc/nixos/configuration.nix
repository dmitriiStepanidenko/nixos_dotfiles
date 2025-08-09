{
  config,
  pkgs,
  lib,
  inputs,
  rust-overlay,
  #nixpkgs-stable-unstable,
  ...
}: let
  system = pkgs.system;
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
      #permittedInsecurePackages = [
      #  "electron-27.3.11"
      #];
    };
  };
  #surrealist-bin = pkgs.callPackage ../../nix/packages/surrealist.nix {};
in {
  imports = [
    inputs.sops-nix.nixosModules.sops
    ./hardware/hardware-configuration.nix
    ./modules/desktop.nix
    ./modules/cpu.nix
    ./modules/window_manager.nix
    ./modules/fonts_icons.nix
    ./modules/xray.nix
    ./modules/ssh.nix
    ./modules/yubikey.nix
    #./modules/amdgpu_patch.nix
    ./modules/quality_of_programming_life.nix
    ./modules/rustify.nix
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

  i18n = {
    #nixpkgs.overlays = [ (final: prev: ) ];
    extraLocales = [
      "ru_RU.UTF-8/UTF-8"
    ];

    # Select internationalisation properties.
    defaultLocale = "en_US.UTF-8";

    extraLocaleSettings = {
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
  };

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
  programs = {
    sniffnet.enable = true;

    appimage.enable = true;
    appimage.binfmt = true;

    light.enable = true;

    nix-index = {
      enable = true;
      enableFishIntegration = true;
      enableBashIntegration = false;
      enableZshIntegration = false;
    };

    noisetorch.enable = true;

    yazi = {
      enable = true;
      flavors = {
        tokyo-night = tokyoNightTheme;
      };
    };
    neovim.defaultEditor = true;
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

    # Enable CUPS to print documents.
    printing.enable = true;
    printing.drivers = [pkgs.hplipWithPlugin];
    avahi.enable = true;

    # Enable touchpad support (enabled default in most desktopManager).
    libinput = {
      enable = true;
    };
    # multi-touch gesture recognizer
    touchegg.enable = true;

    logind.extraConfig = ''
      HandlePowerKey=suspend
      IdleAction=suspend
      IdleActionSec=1m
    '';

    v2raya.enable = true;
    # TODO:
    #services.sing-box.enable = true;

    playerctld.enable = true; # Media keys

    kanata = {
      enable = true; # keys
      keyboards.default.config = ''
        ;; Kanata configuration for caps to asc+ctrl
        (defsrc
          caps
        )

        (defalias
          escctrl lctrl
        )

        (deflayer base
          @escctrl
        )
      '';
    };
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
    settings = {
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = true;
      #users.defaultUserShell = pkgs.fish;
      trusted-users = ["root" "dmitrii"];
      max-jobs = 3;
      cores = 6;
      show-trace = true;
    };

    optimise.automatic = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 4d";
    };
    extraOptions = ''
      min-free = ${toString (20 * 1024 * 1024 * 1024)}
      max-free = ${toString (20 * 1024 * 1024 * 1024)}
    ''; # Free up 20GiB whenever there is less than 20 GiB left
  };
  hardware = {
    # acpi thermal readings??
    acpilight.enable = true;

    keyboard.qmk.enable = true;

    # bluetooth
    bluetooth = {
      enable = true;
      powerOnBoot = false;
      input = {
        General = {
          UserspaceHID = true;
          Experimental = true;
        };
      };
    };
  };

  powerManagement.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Moscow";
  console.keyMap = "us";
  virtualisation = {
    podman = {
      enable = true;
    };
    docker = {
      enable = true;
      #rootless = {
      #  enable = true;
      #  setSocketVariable = true;
      #  daemon.settings = {
      #    insecure-registries = ["10.252.1.8:5000"];
      #  };
      #};
      package = pkgs.docker;
      autoPrune.enable = true;
      autoPrune.dates = "weekly";
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
  users.users.dmitrii = {
    isNormalUser = true;
    shell = pkgs.fish;
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
  };
  users.groups.dmitrii.gid = 1000;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  services.flatpak.enable = true;

  environment.systemPackages = with pkgs; [
    cri-tools
    dive # look into docker image layers
    podman-tui # status of containers in the terminal
    docker-compose # start group of containers for dev

    wget
    displaylink
    neofetch
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

    ueberzugpp # Display images in alacritty

    #komorebi
    xwinwrap

    ffmpeg-full

    imagemagick

    unrar-wrapper
    p7zip
    _7zz # rar archives

    lazygit

    # TODO

    unstable.clang-tools

    hplipWithPlugin # hp printer

    getent

    #lldb # debugging

    mdbook

    playerctl # Media keys: Play/Pause / etc

    # cmake # needs for cargo-semver-checks
    cargo-semver-checks

    kanata # for remapping of keys

    lm_sensors # reding hardware temperature sensors

    # Undervolting (for Intel :(  ) !
    undervolt
    s-tui
    stress
    # Undervolting !

    acpi

    dmidecode

    vhdl-ls

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

    inputs.surrealist.legacyPackages.${pkgs.system}.surrealist
    #surrealist-bin
    #pkgs.nixgl.nixGLIntel
    #pkgs.nixgl.nixVulkanIntel

    nixos-anywhere

    hub

    apacheHttpd # because of htpasswd

    nix-output-monitor
    nix-fast-build
  ];

  services.searx = {
    enable = true;
    redisCreateLocally = true;

    # Rate limiting
    limiterSettings = {
      real_ip = {
        x_for = 1;
        ipv4_prefix = 32;
        ipv6_prefix = 56;
      };

      botdetection = {
        ip_limit = {
          filter_link_local = true;
          link_token = true;
        };
      };
    };
    settings.server = {
      bind_address = "127.0.0.1";
      # port = yourPort;
      # WARNING: setting secret_key here might expose it to the nix cache
      # see below for the sops or environment file instructions to prevent this
      secret_key = config.sops.secrets."searx/secret_key".path;
    };
  };
  sops.secrets = {
    "searx/secret_key" = {
      owner = "searx";
      mode = "0400";
      restartUnits = ["searx.service"];
    };
  };

  system.stateVersion = "25.05";

  #boot.kernelPackages = unstable.linuxPackages_6_13;
  boot.kernelPackages = unstable.linuxPackages_latest;
}
