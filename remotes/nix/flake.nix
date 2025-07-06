{
  inputs = {
    surrealdb = {
      url = "github:dmitriiStepanidenko/surrealdb-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wireguard = {
      url = "github:dmitriiStepanidenko/wireguard-nixos-private";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    sccache = {
      url = "github:dmitriiStepanidenko/sccache-nix";
    };

    vm-profile = {
      url = "github:dmitriiStepanidenko/my-proxmox-vm-profile-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs-master.url = "github:nixos/nixpkgs";

    nixos-unstable.follows = "nixpkgs-unstable";

    todo-backend = {
      url = "git+ssh://git@10.252.1.0:9050/graph-learning/todo-nix.git";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.flake-utils.follows = "flake-utils";
    };

    colmena = {
      url = "github:zhaofengli/colmena?ref=main";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.flake-utils.follows = "flake-utils";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    buildbot-nix = {
      url = "github:nix-community/buildbot-nix?ref=e09b4c0588ce95fd72993adb5af198d5ba32e752";
      #inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };
  outputs = inputs @ {
    self,
    colmena,
    nixpkgs,
    nixpkgs-unstable,
    sops-nix,
    vm-profile,
    nixos-generators,
    flake-utils,
    ...
  }: let
    system = "x86_64-linux";
    pkgs_unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
    pkgs = import nixpkgs {
      config.allowUnfree = true;
      #system = "x86_64-linux";
      inherit system;
    };
  in {
    colmenaHive = colmena.lib.makeHive self.outputs.colmena;
    colmena = {
      meta = {
        nixpkgs = pkgs;
        nodeSpecialArgs = {
          todo-staging = {
          };
        };
        specialArgs = {
          inherit inputs system;
        };
      };

      defaults = {...}: {
        imports = [
          sops-nix.nixosModules.sops
          vm-profile.nixosModules.default
        ];
      };
      woodpecker_server = {...}: {
        deployment = {
          targetHost = "192.168.0.215";
          targetPort = 22;
          targetUser = "root";
        };
        time.timeZone = "Europe/Moscow";
        imports = [
          ../../nix/hosts/woodpecker_server/default.nix
        ];
      };
      woodpecker_agent = {...}: {
        deployment = {
          targetHost = "192.168.0.211";
          targetPort = 22;
          targetUser = "root";
        };
        time.timeZone = "Europe/Moscow";
        imports = [
          ../../nix/hosts/woodpecker_agent/default.nix
          {
            woodpecker_agent.package = pkgs_unstable.woodpecker-agent;
            environment.systemPackages = [
              pkgs_unstable.nix-eval-jobs
            ];
          }
        ];
      };
      grafana = {...}: {
        deployment = {
          targetHost = "192.168.0.217";
          targetPort = 22;
          targetUser = "root";
        };
        time.timeZone = "Europe/Moscow";
        imports = [
          ../../nix/hosts/grafana/default.nix
        ];
      };
      openobserve = {...}: {
        deployment = {
          targetHost = "192.168.0.218";
          targetPort = 22;
          targetUser = "root";
        };
        time.timeZone = "Europe/Moscow";
        imports = [
          ../../nix/hosts/openobserve/default.nix
        ];
      };
      registry = {...}: {
        deployment = {
          targetHost = "192.168.0.212";
          targetPort = 22;
          targetUser = "root";
        };
        time.timeZone = "Europe/Moscow";
        imports = [
          ../../nix/hosts/registry/default.nix
        ];
      };
      nginx_local = {...}: {
        deployment = {
          targetHost = "192.168.0.213";
          targetPort = 22;
          targetUser = "root";
        };
        time.timeZone = "Europe/Moscow";
        imports = [
          ../../nix/hosts/nginx_local/default.nix
        ];
      };
    };
    #devShells.default.${system} = pkgs_unstable.mkShell {
    #  packages = [colmena.defaultPackage.${system}];
    #  shellHook = ''
    #    export PS1='\[\e[32m\][\u@\H:nix-develop:\w]\\$\[\e[0m\] '
    #  '';
    #};
    devShells.${system}.default = pkgs_unstable.mkShell {
      packages = [colmena.defaultPackage.${system}];
      shellHook = ''
        export PS1='\[\e[32m\][\u@\H:nix-develop:\w]\\$\[\e[0m\] '
      '';
    };
    packages.${system} = {
      iso = nixos-generators.nixosGenerate {
        specialArgs = {inherit inputs system sops-nix vm-profile;};
        inherit system;
        modules = [
          ../../nix/hosts/isoimage/configuration.nix
          {
            networking = {
              # Disable DHCP globally
              dhcpcd.enable = false;
              useDHCP = false;

              # Configure the specific interface
              interfaces.ens3 = {
                useDHCP = false;
                ipv4.addresses = [
                  {
                    address = "176.123.169.226";
                    prefixLength = 32;
                  }
                ];
                ipv6.addresses = [
                  {
                    address = "fe80::5054:ff:fe11:f723";
                    prefixLength = 64;
                  }
                ];
              };
            };
          }
        ];
        format = "iso";
      };
    };
    vm-default-iso = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs system sops-nix vm-profile;};
      inherit system;
      modules = [
        ../../nix/hosts/isoimage/configuration.nix
      ];
    };
  };
}
#wakapi = {...}: {
#  deployment = {
#    targetHost = "192.168.0.216";
#    targetPort = 22;
#    targetUser = "root";
#  };
#  time.timeZone = "Europe/Moscow";
#  imports = [
#    ../../nix/hosts/wakapi/default.nix
#  ];
#};
#backup = {...}: {
#  deployment = {
#    targetHost = "176.123.169.226";
#    targetPort = 22;
#    targetUser = "root";
#  };
#  time.timeZone = "Europe/Moscow";
#  imports = [
#    ../../nix/hosts/backup/default.nix
#  ];
#};
# Disabled for now
#gitea_woker_1 = {...}: {
#  deployment = {
#    targetHost = "192.168.0.210";
#    targetPort = 22;
#    targetUser = "root";
#  };
#  time.timeZone = "Europe/Moscow";
#  imports = [
#    ../../nix/hosts/gitea_worker/default.nix
#  ];
#};

