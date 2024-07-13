{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.05";
    nixpkgsunstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = {nixpkgs, ...} @ inputs:
  #let
  #  pkgs = nixpkgs.legacyPackages.x86_64-linux;
  #  pkgsold = inputs.nixpkgsunstable.legacyPackages.x86_64-linux;
  #in
  {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        ./configuration.nix
      ];
    };

    #packages.x86_64-linux.hello = nixpkgs.anki-bin;
    #packages.x86_64-linux.default = pkgs;

    #packages.x86_linux.default = nixpkgs.mkShell {
    #  buildInputs = [
    #    nixpkgs.anki-bin
    #  ];
    #};
  };
}
