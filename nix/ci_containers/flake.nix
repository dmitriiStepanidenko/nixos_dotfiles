{
  inputs = {
    docker-nixpkgs = {
      url = "github:nix-community/docker-nixpkgs";
      flake = false;
    };
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
    #nixos-24-11.url = "github:nixos/nixpkgs?ref=nixos-24.11";
    #nixpkgs.follows = "nixos-24-11";
    flake-utils.url = "github:numtide/flake-utils";

    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };
  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-unstable,
    flake-utils,
    docker-nixpkgs,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
      pkgsUnstable = import nixpkgs-unstable {inherit system;};
      buildImageWithNix = import ("${docker-nixpkgs}" + "/images/nix/default.nix");
    in {
      packages = rec {
        dockerImage = pkgs.dockerTools.buildLayeredImage {
          fromImage = nixImage;
          tag = "latest";
          name = "my_custom_test_nix_image";
          contents = [
          ];
          config = {
            Cmd = ["${pkgs.bash}/bin/bash"];
            Env = [
              "NIX_CONFIG=experimental-features = nix-command flakes"
            ];
          };
          includeNixDB = true;
        };
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
            bash
          ];
        };
      };
    });
}
