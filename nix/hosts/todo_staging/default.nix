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
    inputs.wireguard.nixosModules.default
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
    inputs.surrealdb.nixosModules.default
  ];

  config = {
    networking.firewall.allowedUDPPorts = [55000 8000];
    networking.firewall.allowedTCPPorts = [55000 8000];
    environment.systemPackages = [
      #inputs.todo-backend.packages.${system}.staging
      inputs.surrealdb.packages.${system}.latest
    ];
    services.surrealdb-bin = {
      enable = true;
      package = inputs.surrealdb.packages.${system}.latest;
      auth = {
        username = "root";
        passwordFile = config.sops.secrets."surrealdb/password".path;
      };
    };
    services.todo-backend = {
      enable = true;
      pkg =
        inputs.todo-backend.packages.${system}.staging;
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
      additionalAfterServices = ["surrealdb.service"];
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
        "surrealdb/password" = {
          owner = "surrealdb";
          group = "surrealdb";
          mode = "0400";
          restartUnits = ["surrealdb.service"];
        };
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
