{
  config,
  pkgs,
  modulesPath,
  lib,
  system,
  ...
}: let
  dataDir = "/data/webserver/root";
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
        ips = "10.252.1.9/24";
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
  ];

  config = {
    systemd.services.sftpgo.serviceConfig.UMask = lib.mkForce "022";
    systemd.tmpfiles.rules = ["Z ${dataDir} 755 sftpgo nginx - -"];
    networking = {
      hostName = "nginx_local";
      firewall = {
        interfaces.wg0 = {
          allowedTCPPorts = [80 22 8080 2222];
          allowedUDPPorts = [80 22 8080 2222];
        };
        allowedTCPPorts = [80 22 8080 2222];
        allowedUDPPorts = [80 22 8080 2222];
        enable = true;
      };
    };
    services.sftpgo = {
      enable = true;
      dataDir = "/var/lib/sftpgo";
      user = "sftpgo";
      group = "nginx";
      extraReadWriteDirs = [dataDir];
      inherit (config.sftpgo) package;
      settings = {
        umask = "022";
        sftpd.bindings = [
          {
            address = "10.252.1.9";
            port = 2222;
          }
          {
            address = "192.168.0.213";
            port = 2222;
          }
        ];
        httpd.bindings = [
          {
            address = "10.252.1.9";
            port = 8080;
            enable_web_admin = true;
          }
        ];
      };
    };
    services.nginx = {
      enable = true;
      user = "nginx";
      group = "nginx";
      virtualHosts."10.252.1.9" = {
        root = dataDir;
        locations."/" = {
          extraConfig = ''
            autoindex on;
          '';
        };
        #locations."/gamechanger-docs" = {
        #  extraConfig = ''
        #    autoindex on;
        #  '';
        #};
        #enableACME = false;
        #forceSSL = false;
        #default = true;
        #listen = [
        #  {
        #    addr = "10.252.1.9";
        #    port = 80;
        #    ssl = false;
        #  }
        #];
      };
      #defaultListen = [
      #  {
      #    addr = "0.0.0.0";
      #    ssl = false;
      #  }
      #];
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
    };
  };
}
