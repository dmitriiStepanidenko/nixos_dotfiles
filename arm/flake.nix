{
  inputs = {
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

    colmena = {
      url = "github:zhaofengli/colmena?ref=main";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.flake-utils.follows = "flake-utils";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    raspi-camera = {
      # [1]
      url = "github:sergei-mironov/nixos-raspi-camera";
      #inputs.nixpkgs.follows = "nixpkgs"; # [2]
    };
  };
  outputs = inputs @ {
    self,
    colmena,
    nixpkgs,
    nixpkgs-unstable,
    sops-nix,
    vm-profile,
    flake-utils,
    ...
  }: let
    system = "aarch64-linux";
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

      piwatch = {...}: {
        deployment = {
          #targetHost = "192.168.0.200";
          targetHost = "192.168.0.145";
          targetPort = 22;
          targetUser = "root";
        };
        time.timeZone = "Europe/Moscow";
        imports = [
          ../nix/hosts/piwatch/default.nix
        ];
      };
    };
    devShells.x86_64-linux.default = pkgs_unstable.mkShell {
      packages = [colmena.defaultPackage."x86_64-linux"];
      shellHook = ''
        export PS1='\[\e[32m\][\u@\H:nix-develop:\w]\\$\[\e[0m\] '
      '';
    };
  };
}
