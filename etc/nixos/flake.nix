{
  description = "Mine flake";

  inputs = {
    nixos-24-11.url = "github:nixos/nixpkgs?ref=nixos-24.11";
    nixos-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    nixpkgs.follows = "nixos-24-11";
    nixpkgs_unstable.follows = "nixos-unstable";

    nixos-24-11-stable-xsecurelock.url = "github:nixos/nixpkgs?ref=d3c42f187194c26d9f0309a8ecc469d6c878ce33";

    neovim-nightly-overlay.url = "https://github.com/nix-community/neovim-nightly-overlay/archive/1f54e89757bd951470a9dcc8d83474e363f130c5.tar.gz";
    nixvim = {
      #url = "github:nix-community/nixvim";
      url = "github:nix-community/nixvim?ref=3d24cb72618738130e6af9c644c81fe42aa34ebc";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf.url = "github:notashelf/nvf";

    colmena.url = "github:zhaofengli/colmena?ref=main";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs_unstable,
    colmena,
    nvf,
    #sops-nix,
    ...
  }: let
    system = "x86_64-linux";
  in {
    packages."x86_64-linux".default =
      (
        nvf.lib.neovimConfiguration {
          pkgs = nixpkgs_unstable.legacyPackages.${system};
          modules = [../../nix/modules/nvf-configuration.nix];
        }
      )
      .neovim;

    nixosConfigurations = {
      nixos = inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ({pkgs, ...}: {
            environment.systemPackages = [
              colmena.defaultPackage.x86_64-linux
            ];
          })
          ./configuration.nix
          nvf.nixosModules.default
          #sops-nix.nixosModules.sops
          #{
          #  _module.args = {
          #    modulesPath = "./modules";
          #  };
          #}
          # ./neovim.nix
        ];
      };
    };
    devShells.system.default =
      inputs.nixpkgs-unstable.mkShell
      {
        nativeBuildInputs = with inputs.nixpkgs-unstable; [
          #nodejs
          clang-tools
          inputs.nixpkgs-stable.legacyPackages.${system}.systemc
        ];
      };
  };
}
