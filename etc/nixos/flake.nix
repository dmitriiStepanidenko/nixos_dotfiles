{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.05";
    nixpkgsunstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { nixpkgs, ... } @ inputs: 
  let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
    pkgsold = inputs.nixpkgsveryold.legacyPackages.x86_64-linux;
  in
  {

    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ../etc/nixos/configuration.nix
      ];
    };

    #packages.x86_64-linux.hello = pkgs.hello;
    #packages.x86_64-linux.default = pkgs.hello;

    #devShells.x86_linux.default = pkgs.mkShell {
    #  buildInputs = [ pkgs.neovim pkgsold.vim ];
    #};
  };
}
