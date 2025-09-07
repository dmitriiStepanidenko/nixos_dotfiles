{
  description = "Mine flake";

  inputs = {
    sccache = {
      url = "github:dmitriiStepanidenko/sccache-nix";
    };
    surrealdb.url = "github:dmitriiStepanidenko/surrealdb-nixos";
    wireguard.url = "github:dmitriiStepanidenko/wireguard-nixos-private";
    #wireguard.url = "git+file:/home/dmitrii/tmp/wireguard-nixos-private";

    #nixos-25-05.url = "github:nixos/nixpkgs?ref=release-25.05";
    nixos-25-05.url = "github:nixos/nixpkgs?ref=5eb9271c6e5096d5bb9af338448efc30b11b84f0";
    nixos-24-11.url = "github:nixos/nixpkgs?ref=nixos-24.11";
    nixos-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    nixpkgs.follows = "nixos-25-05";
    nixpkgs_unstable.follows = "nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs_unstable";
    };

    mnw.url = "github:Gerg-L/mnw";
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.mnw.follows = "mnw";
    };
    nixgl = {
      #nvf.url = "github:dmitriiStepanidenko/nvf";
      #nvf.url = "path:/home/dmitrii/shared/tmp/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/nixGL";
    };

    surrealist.url = "github:dmitriiStepanidenko/nixpkgs?ref=origin/surrealist";

    colmena.url = "github:zhaofengli/colmena?ref=main";

    hyprland = {
      url = "github:hyprwm/Hyprland?submodules=1&ref=d7a87ce6e2535f1029fc93b062d2828e8549c525";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprlock = {
      url = "github:hyprwm/hyprlock";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
    rust-overlay,
    sccache,
    home-manager,
    nixgl,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs_unstable.legacyPackages.${system}.extend rust-overlay.overlays.default;

    extensions = [
      "rust-src"
      "rust-analyzer"
      "clippy"
    ];

    rust = pkgs.rust-bin.stable.latest.default.override {
      inherit extensions;
    };
  in {
    packages.${system}.my-neovim =
      (
        nvf.lib.neovimConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit inputs;
          };

          modules = [
            ../../nix/modules/nvf-configuration.nix
            ({
              config,
              pkgs,
              ...
            }: {
              #config.vim.languages.rust.lsp.package = ["rust-analyzer"];
              #config.vim.languages.rust.format.package = ["rustfmt"];
            })
          ];
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
              colmena.defaultPackage.${system}
            ];
          })
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              extraSpecialArgs = {
                inherit inputs;
              };
              sharedModules = [
                inputs.sops-nix.homeManagerModules.sops
              ];

              users.dmitrii = import ./home-manager/dmitrii.nix;
            };
          }
          ({pkgs, ...}: {
            nixpkgs.overlays = [
              rust-overlay.overlays.default
              nixgl.overlay
            ];
            environment = {
              variables = {
                MANPAGER = "nvim +Man!";
              };
              systemPackages = [
                self.packages.${system}.my-neovim
                pkgs.pkg-config
                pkgs.mold
                pkgs.clang
                rust
                sccache.packages.${system}.sccache
              ];
              variables.EDITOR = "${self.packages.${system}.my-neovim}/bin/nvim";
              variables.SUDO_EDITOR = "${self.packages.${system}.my-neovim}/bin/nvim";
            };
          })
        ];
      };
    };
    devShells.${system}.default =
      inputs.nixpkgs-unstable.mkShell
      {
        nativeBuildInputs = with inputs.nixpkgs-unstable; [
          clang-tools
          inputs.nixpkgs-stable.legacyPackages.${system}.systemc
        ];
      };
  };
}
