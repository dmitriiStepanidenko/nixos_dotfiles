{
  config,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./network.nix
    ./disk-config.nix
    ./gitea.nix
  ];
  config = {
    boot.loader.grub.enable = lib.mkForce false;
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    services.cloud-init.enable = false;
    networking.hostName = "dev";
    sops = {
      defaultSopsFile = ./secrets.yaml;
      defaultSopsFormat = "yaml";
      age = {
        sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
        keyFile = "/var/lib/sops-nix/key.txt";
        generateKey = true;
      };
      #secrets = {
      #  "wireguard/wireguard_ip" = {
      #    owner = config.users.users.systemd-network.name;
      #    mode = "0400";
      #    restartUnits = ["wireguard-setup.service"];
      #  };
      #  "wireguard/private_key" = {
      #    owner = config.users.users.systemd-network.name;
      #    mode = "0400";
      #    restartUnits = ["wireguard-setup.service"];
      #  };
      #  "wireguard/preshared_key" = {
      #    owner = config.users.users.systemd-network.name;
      #    mode = "0400";
      #    restartUnits = ["wireguard-setup.service"];
      #  };
      #  "wireguard/public_key" = {
      #    owner = config.users.users.systemd-network.name;
      #    mode = "0400";
      #    restartUnits = ["wireguard-setup.service"];
      #  };
      #};
    };
  };
}
