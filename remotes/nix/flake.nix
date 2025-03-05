{
  inputs = {
    surrealdb.url = "github:dmitriiStepanidenko/surrealdb-nixos";
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
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs @ {
    self,
    colmena,
    nixpkgs,
    nixpkgs-unstable,
    sops-nix,
    todo-backend,
    ...
  }: let
    system = "x86_64-linux";
    pkgs_unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
      #overlays = [
      #  (import ../../nix/overlays/todo-backend.nix)
      #];
    };
  in {
    colmenaHive = colmena.lib.makeHive self.outputs.colmena;
    colmena = {
      meta = {
        nixpkgs = import nixpkgs {
          config.allowUnfree = true;
          system = "x86_64-linux";
        };
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
          ../backup_image/nix/vm-profile.nix
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
      woodpecker_agent_1 = {...}: {
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
          {
            #sftpgo.package = pkgs_unstable.sftpgo;
          }
        ];
      };
      todo-staging = {...}: {
        deployment = {
          targetHost = "192.168.0.220";
          targetPort = 22;
          targetUser = "root";
        };
        time.timeZone = "Europe/Moscow";
        imports = [
          ../../nix/hosts/todo_staging/default.nix
          #todo-backend.nixosModules.default
        ];
        #services.todo-backend = {
        #  enable = true;
        #};
      };
    };
  };
}
