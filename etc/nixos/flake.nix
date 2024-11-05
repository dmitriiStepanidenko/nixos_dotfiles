{
  description = "A very basic flake";

  inputs = {
    #nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.05";
    #nixpkgs-nvidia-beta.url = "github:Kiskae/nixpkgs?ref=nvidia/560.28.03";
    nixpkgs-stable.url = "github:nixos/nixpkgs?ref=nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
    nixos-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-stable-unstable.url = "github:nixos/nixpkgs?ref=5e0ca22929f3342b19569b21b2f3462f053e497b";
    neovim-nightly-overlay.url = "https://github.com/nix-community/neovim-nightly-overlay/archive/1f54e89757bd951470a9dcc8d83474e363f130c5.tar.gz";
    nixvim = {
      #url = "github:nix-community/nixvim";
      url = "github:nix-community/nixvim?ref=3d24cb72618738130e6af9c644c81fe42aa34ebc";
      # If you are not running an unstable channel of nixpkgs, select the corresponding branch of nixvim.
      # url = "github:nix-community/nixvim/nixos-24.05";

      inputs.nixpkgs.follows = "nixpkgs";
    };

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
    #overlays = [
    #  inputs.neovim-nightly-overlay.overlays.default
    #];
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
