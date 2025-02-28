{
  config,
  pkgs,
  modulesPath,
  lib,
  system,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    #(modulesPath + "/virtualisation/proxmox-image.nix")
  ];

  config = {
    nix = {
      optimise.automatic = true;
      gc = {
        automatic = true;
        dates = "daily";
        options = "--delete-older-than 7d";
      };
      extraOptions = ''
        min-free = ${toString (100 * 1024 * 1024)}
        max-free = ${toString (1024 * 1024 * 1024)}
      '';
      settings = {
        auto-optimise-store = true;

        # Allow remote updates with flakes and non-root users
        trusted-users = ["root" "@wheel" "dmitrii"];
        experimental-features = ["nix-command" "flakes"];
      };
    };

    #Provide a default hostname
    networking.hostName = lib.mkDefault "base";
    services = {
      # Enable QEMU Guest for Proxmox
      qemuGuest.enable = true;
      avahi = {
        # Enable mDNS for `hostname.local` addresses
        enable = true;
        nssmdns4 = true;
        publish = {
          enable = true;
          addresses = true;
        };
      };

      fail2ban = {
        enable = true;
        maxretry = 5;
      };

      # Enable ssh
      openssh = {
        enable = true;
        settings.PasswordAuthentication = false;
        settings.KbdInteractiveAuthentication = false;
      };

      openssh.openFirewall = true;

      cloud-init.enable = true;
    };
    boot = {
      # Use the boot drive for grub
      loader.grub.enable = lib.mkDefault true;
      loader.grub.devices = ["nodev"];

      growPartition = lib.mkDefault true;
    };

    # Some sane packages we need on every system
    environment.systemPackages = with pkgs; [
      vim # for emergencies
      neovim
      git # for pulling nix flakes
      python3 # for ansible
      htop
      wget
      curl
    ];

    # Don't ask for passwords
    security.sudo.wheelNeedsPassword = false;
    users = {
      users = {
        "dmitrii".uid = 1000;
        "dmitrii".isNormalUser = true;
        "dmitrii".group = "dmitrii";
        "dmitrii".extraGroups = ["wheel" "docker" "networkmanager"];
        "dmitrii".openssh.authorizedKeys.keyFiles = [
          ../../../id_rsa.pub
        ];

        "root".openssh.authorizedKeys.keyFiles = [
          ../../../id_rsa.pub
        ];
      };
      groups.dmitrii.gid = 1000;
    };

    programs.ssh.startAgent = true;

    # Default filesystem
    fileSystems."/" = lib.mkDefault {
      device = "/dev/disk/by-label/nixos";
      autoResize = true;
      fsType = "ext4";
    };

    system.stateVersion = lib.mkDefault "24.11";
    #services.cloud-init.network.enable = true;
  };
}
