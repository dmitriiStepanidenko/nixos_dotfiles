{
  config,
  pkgs,
  lib,
  inputs,
  system,
  ...
}: {
  options.woodpecker_agent.package = lib.mkOption {
    type = lib.types.package;
    default = pkgs.woodpecker-agent;
  };
  imports = [
    inputs.wireguard.nixosModules.default
    {
      services.wireguard = {
        enable = true;
        ips = "10.252.1.11/24";
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
  ];
  config = {
    environment.systemPackages = [
      inputs.colmena.defaultPackage.${system}
    ];
    networking.firewall = {
      allowedUDPPorts = [
        3000
        80
      ];
      allowedTCPPorts = [
        3000
        80
      ];
      interfaces.wg0 = {
        allowedUDPPorts = [
          3000
          80
          9001
        ];
        allowedTCPPorts = [
          3000
          9001
          80
        ];
      };
    };
    services = {
      grafana = {
        enable = true;
        settings = {
          server = {
            # Listening Address
            http_addr = "10.252.1.11";
            #http_addr = "127.0.0.1";
            # and Port
            http_port = 3000;
            # Grafana needs to know on which domain and URL it's running
            domain = "10.252.1.11";
            #root_url = "http://10.252.1.11/"; # Not needed if it is `https://your.domain/`
            serve_from_sub_path = true;
          };
        };
      };
      #nginx = {
      #  enable = true;
      #  virtualHosts.${config.services.grafana.domain} = {
      #    locations."/" = {
      #      proxyPass = "http://127.0.0.1:${toString config.services.grafana.port}";
      #      proxyWebsockets = true;
      #    };
      #  };
      #};
      prometheus = {
        enable = true;
        port = 9001;
        exporters = {
          node = {
            enable = true;
            enabledCollectors = ["systemd"];
            port = 9002;
          };
        };
        scrapeConfigs = [
          {
            job_name = "grafana";
            static_configs = [
              {
                targets = ["127.0.0.1:${toString config.services.prometheus.exporters.node.port}"];
              }
            ];
          }
          {
            job_name = "nginx";
            static_configs = [
              {
                targets = ["10.252.1.9:9002"];
              }
            ];
          }
          {
            job_name = "registry";
            static_configs = [
              {
                targets = ["10.252.1.8:9002"];
              }
            ];
          }
          {
            job_name = "gitea_worker";
            static_configs = [
              {
                targets = ["10.252.1.4:9002"];
              }
            ];
          }
          {
            job_name = "wakapi";
            static_configs = [
              {
                targets = ["10.252.1.6:9002"];
              }
            ];
          }
          {
            job_name = "woodpecker-agent";
            static_configs = [
              {
                targets = ["10.252.1.7:9002"];
              }
            ];
          }
          {
            job_name = "woodpecker-server";
            static_configs = [
              {
                targets = ["10.252.1.5:9002"];
              }
            ];
          }
        ];
      };
    };

    networking.hostName = "grafana";
    sops = {
      defaultSopsFile = ./secrets.yaml;
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
    };
  };
}
