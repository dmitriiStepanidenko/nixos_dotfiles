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
    #Provide a default hostname
    networking.hostName = lib.mkDefault "base";

    # Enable QEMU Guest for Proxmox
    services.qemuGuest.enable = true;

    # Use the boot drive for grub
    boot.loader.grub.enable = lib.mkDefault true;
    boot.loader.grub.devices = ["nodev"];

    boot.growPartition = lib.mkDefault true;

    # Allow remote updates with flakes and non-root users
    nix.settings.trusted-users = ["root" "@wheel" "dmitrii"];
    nix.settings.experimental-features = ["nix-command" "flakes"];

    # Enable mDNS for `hostname.local` addresses
    services.avahi.enable = true;
    services.avahi.nssmdns4 = true;
    services.avahi.publish = {
      enable = true;
      addresses = true;
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

    services.fail2ban = {
      enable = true;
      maxretry = 5;
    };

    # Don't ask for passwords
    security.sudo.wheelNeedsPassword = false;

    # Enable ssh
    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
    };
    users.users."dmitrii" = {
      uid = 1000;
      isNormalUser = true;
      group = "dmitrii";
      extraGroups = ["wheel" "docker" "networkmanager"];
      openssh.authorizedKeys.keyFiles = [
        ../../../id_rsa.pub
      ];
    };
    programs.ssh.startAgent = true;
    users.groups.dmitrii.gid = 1000;

    services.openssh.openFirewall = true;

    users.users."root" = {
      openssh.authorizedKeys.keyFiles = [
        ../../../id_rsa.pub
      ];
    };

    # Default filesystem
    fileSystems."/" = lib.mkDefault {
      device = "/dev/disk/by-label/nixos";
      autoResize = true;
      fsType = "ext4";
    };

    system.stateVersion = lib.mkDefault "24.11";

    services.cloud-init.enable = true;
    #services.cloud-init.network.enable = true;
  };
}
