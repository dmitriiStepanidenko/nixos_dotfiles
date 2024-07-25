{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.05";
    nixpkgsunstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }: let
    system = "x86_64-linux";
    #  pkgs = nixpkgs.legacyPackages.x86_64-linux;
    #  pkgsold = inputs.nixpkgsunstable.legacyPackages.x86_64-linux;
  in {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          ./configuration.nix
        ];
      };
    };
    #nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
    #  specialArgs = {inherit inputs outputs;};
    #  modules = [
    #    ./configuration.nix
    #  ];
    #};

    packages.x86_64-linux.anki-bin = nixpkgs.anki-bin;
    #packages.x86_64-linux.default = nixpkgs;

    #packages.x86_linux.default = nixpkgs.mkShell {
    #  buildInputs = [
    #    nixpkgs.anki-bin
    #  ];
    #};
  };
}
