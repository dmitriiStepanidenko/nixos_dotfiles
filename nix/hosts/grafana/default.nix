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
        3030
      ];
      interfaces.wg0 = {
        allowedUDPPorts = [
          3030
          3000
          80
          9001
        ];
        allowedTCPPorts = [
          3030
          3000
          9001
          80
        ];
      };
    };
    systemd.services = {
      grafana.serviceConfig = {
        RestartSec = 25;
      };
      loki.serviceConfig = {
        RestartSec = 25;
      };
      prometheus.serviceConfig = {
        RestartSec = 25;
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
      loki = {
        enable = true;
        configuration = {
          server.http_listen_port = 3030;
          auth_enabled = false;

          ingester = {
            lifecycler = {
              address = "127.0.0.1";
              ring = {
                kvstore = {
                  store = "inmemory";
                };
                replication_factor = 1;
              };
            };
            chunk_idle_period = "1h";
            max_chunk_age = "1h";
            chunk_target_size = 999999;
            chunk_retain_period = "30s";
            #max_transfer_retries = 0;
          };

          schema_config = {
            configs = [
              {
                from = "2025-01-01";
                store = "tsdb";
                object_store = "filesystem";
                schema = "v13";
                index = {
                  prefix = "index_";
                  period = "24h";
                };
              }
            ];
          };

          storage_config = {
            tsdb_shipper = {
              active_index_directory = "/var/lib/loki/tsdb-shipper-active";
              cache_location = "/var/lib/loki/tsdb-shipper-cache";
              cache_ttl = "24h";
              #shared_store = "filesystem";
            };

            filesystem = {
              directory = "/var/lib/loki/chunks";
            };
          };

          limits_config = {
            reject_old_samples = true;
            reject_old_samples_max_age = "168h";
          };

          chunk_store_config = {
            #max_look_back_period = "0s";
          };

          table_manager = {
            retention_deletes_enabled = false;
            retention_period = "0s";
          };

          compactor = {
            working_directory = "/var/lib/loki";
            #shared_store = "filesystem";
            compactor_ring = {
              kvstore = {
                store = "inmemory";
              };
            };
          };
        };
      };
      prometheus = {
        enable = true;
        port = 9001;
        #exporters = {
        #  node = {
        #    enable = true;
        #    enabledCollectors = ["systemd"];
        #    port = 9002;
        #  };
        #};
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
          {
            job_name = "piwatch";
            static_configs = [
              {
                targets = ["10.252.1.13:9002"];
              }
            ];
          }
          {
            job_name = "todo-staging";
            static_configs = [
              {
                targets = ["10.252.1.10:9002"];
              }
            ];
          }
          {
            job_name = "graph-learning-staging";
            static_configs = [
              {
                targets = ["10.252.1.14:9002"];
              }
            ];
          }
          {
            job_name = "openobserve";
            static_configs = [
              {
                targets = ["10.252.1.15:9002"];
              }
            ];
          }
          {
            job_name = "proxmox";
            static_configs = [
              {
                targets = ["192.168.0.148:9002"];
              }
            ];
          }
          {
            job_name = "dev";
            static_configs = [
              {
                targets = ["10.252.1.0:9002"];
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
