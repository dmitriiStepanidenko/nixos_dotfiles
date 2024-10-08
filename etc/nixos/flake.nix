{
  description = "A very basic flake";

  inputs = {
    #nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.05";
    #nixpkgs-nvidia-beta.url = "github:Kiskae/nixpkgs?ref=nvidia/560.28.03";
    nixpkgs-stable.url = "github:nixos/nixpkgs?ref=nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
    nixos-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-stable-unstable.url = "github:nixos/nixpkgs?ref=5e0ca22929f3342b19569b21b2f3462f053e497b";

    sops-nix = {
      url = "github:Mic92/sops-nix";
    };
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
      nixos = inputs.nixpkgs-unstable.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./configuration.nix
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
    #nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
    #  specialArgs = {inherit inputs outputs;};
    #  modules = [
    #    ./configuration.nix
    #  ];
    #};

    #packages.x86_64-linux.anki-bin = nixpkgs.anki-bin;
    #packages.x86_64-linux.default = nixpkgs;

    # packages.x86_64-linux.develop = nixpkgs.mkShell {
    #   buildInputs = [
    #     nixpkgs.anki-bin
    #   ];
    # };
  };
}
