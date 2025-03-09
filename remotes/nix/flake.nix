{
  inputs = {
    surrealdb = {
      url = "github:dmitriiStepanidenko/surrealdb-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    wireguard = {
      url = "github:dmitriiStepanidenko/wireguard-nixos-private";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    vm-profile = {
      url = "github:dmitriiStepanidenko/my-proxmox-vm-profile-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

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
  };
  outputs = inputs @ {
    self,
    colmena,
    nixpkgs,
    nixpkgs-unstable,
    sops-nix,
    vm-profile,
    ...
  }: let
    system = "x86_64-linux";
    pkgs_unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
    pkgs = import nixpkgs {
      config.allowUnfree = true;
      system = "x86_64-linux";
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
          }
        ];
      };
      wakapi = {...}: {
        deployment = {
          targetHost = "192.168.0.216";
          targetPort = 22;
          targetUser = "root";
        };
        time.timeZone = "Europe/Moscow";
        imports = [
          ../../nix/hosts/wakapi/default.nix
          {
            woodpecker_agent.package = pkgs_unstable.woodpecker-agent;
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
          {
            woodpecker_agent.package = pkgs_unstable.woodpecker-agent;
          }
        ];
      };
      container_registry = {...}: {
        deployment = {
          targetHost = "192.168.0.212";
          targetPort = 22;
          targetUser = "root";
        };
        time.timeZone = "Europe/Moscow";
        imports = [
          ../../nix/hosts/container_registry/default.nix
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
    devShells.${system}.default = pkgs_unstable.mkShell {
      packages = [colmena.defaultPackage.${system}];
      shellHook = ''
        export PS1='\[\e[32m\][\u@\H:nix-develop:\w]\\$\[\e[0m\] '
      '';
    };
  };
}
