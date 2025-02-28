let
  nixos-24-11.url = "github:nixos/nixpkgs?ref=nixos-24.11";

  nixpkgsSrc = fetchGit nixos-24-11;
in
  {
    pkgs ? import nixpkgsSrc {},
    pkgsLinux ? import nixpkgsSrc {system = "x86_64-linux";},
  }:
    pkgs.dockerTools.buildImage {
      name = "hello-docker";
      config = {
        Cmd = ["${pkgsLinux.hello}/bin/hello"];
      };
    }
