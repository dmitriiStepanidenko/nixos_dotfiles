{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    colmena.url = "github:zhaofengli/colmena?ref=main";
  };
  outputs = {
    self,
    colmena,
    nixpkgs,
    ...
  }: {
    colmenaHive = colmena.lib.makeHive self.outputs.colmena;
    colmena = {
      meta = {
        nixpkgs = import nixpkgs {
          config.allowUnfree = true;
          system = "x86_64-linux";
        };
      };

      defaults = {pkgs, ...}: {
        imports = [../backup_image/nix/vm-profile.nix];
      };

      # Also see the non-Flakes hive.nix example above.
      #host-a = { name, nodes, pkgs, ... }: {
      #  boot.isContainer = true;
      #  time.timeZone = nodes.host-b.config.time.timeZone;
      #};
      vpn = {
        deployment = {
          targetHost = "192.168.0.210";
          targetPort = 22;
          targetUser = "root";
        };
        time.timeZone = "Europe/Moscow";
      };
    };
  };
}
