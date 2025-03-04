{
  config,
  pkgs,
  modulesPath,
  lib,
  system,
  inputs,
  ...
}: let
  #unstable = import inputs.nixpkgs-unstable {
  #  inherit system;
  #  config.allowUnfree = true;
  #  overlays = [
  #    (import inputs.todo-backend)
  #  ];
  #};
in {
  options.sftpgo.package = lib.mkOption {
    type = lib.types.package;
    default = pkgs.sftpgo;
  };
  imports = [
    ../../../nix/modules/wireguard.nix
    {
      services.wireguard = {
        enable = true;
        ips = "10.252.1.10/24";
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
    inputs.todo-backend.nixosModules.default
  ];

  config = {
    #environment.systemPackages = [
    #  inputs.todo-backend.packages.${system}.staging
    #];
    services.todo-backend = {
      enable = true;
      pkg =
        inputs.todo-backend.packages.${system}."0.0.1";
      port = 55000;
      address = "0.0.0.0";
      database = {
        address = "ws://localhost:8000";
        namespace = "namespace_test";
        name = "database_test";
      };
      admin = {
        email = "admin@example.com";
        passwordFile = config.sops.secrets."todo-backend/admin_password".path;
      };
      secretFile = config.sops.secrets."todo-backend/secret".path;
      google = {
        redirectUrl = "http://localhost:5173/oauth2/google/callback";
        clientIdFile = config.sops.secrets."todo-backend/google/client_id".path;
        clientSecretFile = config.sops.secrets."todo-backend/google/secret".path;
      };
    };
    sops = {
      defaultSopsFile = ./secrets.yaml;
      defaultSopsFormat = "yaml";
      age = {
        #keyFilePaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
        keyFile = "/var/lib/sops-nix/key.txt";
        generateKey = true;
      };
      secrets = {
        "todo-backend/admin_password" = {
          owner = "todo-backend";
          mode = "0400";
          restartUnits = ["todo-backend.service"];
        };
        "todo-backend/secret" = {
          owner = "todo-backend";
          mode = "0400";
          restartUnits = ["todo-backend.service"];
        };
        "todo-backend/google/client_id" = {
          owner = "todo-backend";
          mode = "0400";
          restartUnits = ["todo-backend.service"];
        };
        "todo-backend/google/secret" = {
          owner = "todo-backend";
          mode = "0400";
          restartUnits = ["todo-backend.service"];
        };
        "wireguard/wireguard_ip" = {
          owner = config.users.users.systemd-network.name;
          mode = "0400";
          restartUnits = ["wireguard.service"];
        };
        "wireguard/private_key" = {
          owner = config.users.users.systemd-network.name;
          mode = "0400";
          restartUnits = ["wireguard.service"];
        };
        "wireguard/preshared_key" = {
          owner = config.users.users.systemd-network.name;
          mode = "0400";
          restartUnits = ["wireguard.service"];
        };
        "wireguard/public_key" = {
          owner = config.users.users.systemd-network.name;
          mode = "0400";
          restartUnits = ["wireguard.service"];
        };
      };
    };
  };
}
