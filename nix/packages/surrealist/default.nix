# default.nix
let
  nixpkgs = fetchTarball "https://github.com/dmitriiStepanidenko/nixpkgs/tarball/origin/surrealist";
  #nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-25.05";
  pkgs = import nixpkgs { config = {}; overlays = []; };
in
{
  surrealist = pkgs.callPackage ./../surrealist.nix { };
}
