{
  description = "Mine flake";

  inputs = {
    nixos-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixos-24-11.url = "github:nixos/nixpkgs?ref=nixos-24.11";
    nixos-24-11-stable-xsecurelock.url = "github:nixos/nixpkgs?ref=d3c42f187194c26d9f0309a8ecc469d6c878ce33";
    neovim-nightly-overlay.url = "https://github.com/nix-community/neovim-nightly-overlay/archive/1f54e89757bd951470a9dcc8d83474e363f130c5.tar.gz";
    nixvim = {
      #url = "github:nix-community/nixvim";
      url = "github:nix-community/nixvim?ref=3d24cb72618738130e6af9c644c81fe42aa34ebc";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    sops-nix,
    ...
  }: let
    system = "x86_64-linux";
  in {
    nixosConfigurations = {
      nixos = inputs.nixos-24-11.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./configuration.nix
          sops-nix.nixosModules.sops
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
