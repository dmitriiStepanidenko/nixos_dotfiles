{
  description = "Template flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
    nixos-24-11.url = "github:nixos/nixpkgs?ref=nixos-24.11";

    sops-nix = {
      url = "github:Mic92/sops-nix";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixos-generators,
    ...
  }: let
    system = "x86_64-linux";
  in {
    packages.${system} = {
      proxmox = nixos-generators.nixosGenerate {
        inherit system;
        modules = [
          ./vm-profile.nix
        ];
        format = "proxmox";
      };
    };
    #nixosConfigurations = {
    #  nixos = inputs.nixos-unstable.lib.nixosSystem {
    #    inherit system;
    #    specialArgs = {
    #      inherit inputs;
    #    };
    #    modules = [
    #      ./vm-profile.nix
    #      {
    #        _module.args = {
    #          #modulesPath = "./modules";
    #          inherit modulesPath;
    #        };
    #      }
    #      # ./neovim.nix
    #    ];
    #  };
    #};
  };
}
