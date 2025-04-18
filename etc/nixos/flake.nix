{
  description = "Mine flake";

  inputs = {
    sccache = {
      url = "github:dmitriiStepanidenko/sccache-nix";
    };
    surrealdb.url = "github:dmitriiStepanidenko/surrealdb-nixos";
    wireguard.url = "github:dmitriiStepanidenko/wireguard-nixos-private";
    #wireguard.url = "git+file:/home/dmitrii/tmp/wireguard-nixos-private";

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

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs_unstable";
    };

    #nvf.url = "github:notashelf/nvf";
    nvf.url = "github:dmitriiStepanidenko/nvf";
    #nvf.url = "path:/home/dmitrii/shared/tmp/nvf";

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
    rust-overlay,
    sccache,
    #sops-nix,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs_unstable.legacyPackages.${system}.extend rust-overlay.overlays.default;

    extensions = [
      "rust-src"
      "rust-analyzer"
      #"rustc-codegen-cranelift-preview"
      "clippy"
    ];

    #getRust = toolchain:
    #  toolchain.default.override {
    #    inherit extensions;
    #  };
    #rust = pkgs.rust-bin.selectLatestNightlyWith getRust;

    rust = pkgs.rust-bin.stable.latest.default.override {
      inherit extensions;
    };
  in {
    packages.${system}.my-neovim =
      (
        nvf.lib.neovimConfiguration {
          #pkgs = inputs.nixos-24-11.legacyPackages.${system};
          inherit pkgs;
          modules = [
            ../../nix/modules/nvf-configuration.nix
            ({
              config,
              pkgs,
              ...
            }: {
              #config.vim.languages.rust.lsp.package = rust;
              config.vim.languages.rust.lsp.package = ["rust-analyzer"];
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
          #nvf.nixosModules.default
          ./configuration.nix
          ({pkgs, ...}: {
            nixpkgs.overlays = [rust-overlay.overlays.default];
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
            #programs.neovim.defaultEditor = true;
          })
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
    devShells.${system}.default =
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
