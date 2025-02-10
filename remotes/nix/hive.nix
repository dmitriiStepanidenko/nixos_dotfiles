let
  NixOS_24_11 = builtins.fetchTarball {
    name = "NixOS-24.11";
    url = "https://github.com/nixos/nixpkgs/archive/nixos-24.11.tar.gz";
    sha256 = "1cb6dmpfsz4zyk41b6z07nhrf20c8b6ryb103kc6088c2vm63ycv";
  };
in
{
  # Here, we can pin Nixpkgs to a specific version. This is some Nix concept beside the scope of this post,
  # but the tl;dr is that it makes our configuration more reproducible in the future, by specifying the exact version of all packages that we use,
  # kind of like a lockfile.
  meta = {
    Nixpkgs = (import NixOS_24_11) {
      config.allowUnfree = true;
      system = "x86_64-linux";
    };
  };

  # This is where we define the base configuration for all hosts
  defaults = { pkgs, ... }: {
    imports = [ ../backup_image/nix/vm-profile.nix ];
  };

  # This is where we define first host
  my-host = { name, nodes, ... }: {
    deployment.targetHost = "192.168.0.210";
    #imports = [ ./hosts/my-host.Nix ];
  };

  # We can define as many hosts as we want, and they will all be deployed
  # when we run `colmena apply`.
}

