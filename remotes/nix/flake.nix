{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    colmena.url = "github:zhaofengli/colmena?ref=main";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    self,
    colmena,
    nixpkgs,
    sops-nix,
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
        imports = [
          sops-nix.nixosModules.sops
          ../backup_image/nix/vm-profile.nix
        ];
      };

      # Also see the non-Flakes hive.nix example above.
      #host-a = { name, nodes, pkgs, ... }: {
      #  boot.isContainer = true;
      #  time.timeZone = nodes.host-b.config.time.timeZone;
      #};
      gitea_woker_1 = {pkgs, ...}: {
        deployment = {
          targetHost = "192.168.0.210";
          targetPort = 22;
          targetUser = "root";
        };
        time.timeZone = "Europe/Moscow";
        imports = [
          ../../nix/hosts/gitea_worker/default.nix
        ];
      };
      woodpecker_agent_1 = {pkgs, ...}: {
        deployment = {
          targetHost = "192.168.0.211";
          targetPort = 22;
          targetUser = "root";
        };
        time.timeZone = "Europe/Moscow";
        imports = [
          ../../nix/hosts/woodpecker_agent/default.nix
        ];
      };
    };
  };
}
