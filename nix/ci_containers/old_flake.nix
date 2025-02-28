{
  inputs = {
    docker-nixpkgs = {
      url = "github:nix-community/docker-nixpkgs";
      flake = false;
    };
    nixos-24-11.url = "github:nixos/nixpkgs?ref=nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";

    nixpkgs.follows = "nixos-24-11";
  };
  outputs = {
    self,
    nixpkgs,
    docker-nixpkgs,
    flake-utils,
    nixos-24-11,
  }: let
    system = "x86_64-linux";
    # pkgs = import nixpkgs {inherit system;};
    pkgs = nixpkgs.legacyPackages.${system};
    buildImageWithNix = import ("${docker-nixpkgs}" + "/images/nix/default.nix");
  in rec {
        flake-utils.lib.eachDefaultSystem (system:
                                let 
    packages.${system}.
                                        nixImage = buildImageWithNix {
      # All of this is required by the function
      inherit
        (pkgs)
        dockerTools
        bashInteractive
        cacert
        coreutils
        curl
        gnutar
        gzip
        iana-etc
        nix
        openssh
        xz
        ;

      # We are actually going to use Git so we use the full version.
      gitReallyMinimal = pkgs.git;

      extraContents = with pkgs; [
        # Since we need git in this image let's add git-lfs right away.
        git-lfs
      ];
    };

    packages.default = pkgs.dockerTools.buildLayeredImage {
      fromImage = packages.${system}.nixImage;
      name = "my-container-image";
      # ...
    };
                                in {
                        }
                                );
  };
}
