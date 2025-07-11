{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";

    vm-profile = {
      url = "github:dmitriiStepanidenko/my-proxmox-vm-profile-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    vm-profile,
    nixpkgs,
    disko,
    nixos-facter-modules,
    ...
  }: {
    # Use this for all other targets
    # nixos-anywhere --flake .#generic --generate-hardware-config nixos-generate-config ./hardware-configuration.nix <hostname>
    nixosConfigurations.generic = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        disko.nixosModules.disko
        ./configuration.nix
        ./hardware-configuration.nix
        ./network.nix
        vm-profile.nixosModules.default
      ];
    };

    # Slightly experimental: Like generic, but with nixos-facter (https://github.com/numtide/nixos-facter)
    # nixos-anywhere --flake .#generic-nixos-facter --generate-hardware-config nixos-facter facter.json <hostname>
    nixosConfigurations.generic-nixos-facter = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        disko.nixosModules.disko
        ./configuration.nix
        nixos-facter-modules.nixosModules.facter
        {
          config.facter.reportPath =
            if builtins.pathExists ./facter.json
            then ./facter.json
            else throw "Have you forgotten to run nixos-anywhere with `--generate-hardware-config nixos-facter ./facter.json`?";
        }
      ];
    };
  };
}
