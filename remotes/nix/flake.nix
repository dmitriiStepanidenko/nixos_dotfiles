{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
  };
  outputs = { nixpkgs, ... }: {
    colmena = {
      meta = {
        nixpkgs = import nixpkgs {
          system = "x86_64-linux";
        };
      };

      # Also see the non-Flakes hive.nix example above.
      #host-a = { name, nodes, pkgs, ... }: {
      #  boot.isContainer = true;
      #  time.timeZone = nodes.host-b.config.time.timeZone;
      #};
      host-b = {
        deployment = {
          targetHost = "192.168.0.210";
          targetPort = 22;
          targetUser = "root";
        };
        boot.isContainer = true;
        time.timeZone = "Europe/Moscow";
      };
    };
  };
}
