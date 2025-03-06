{
  description = "Template flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
    nixos-24-11.url = "github:nixos/nixpkgs?ref=nixos-24.11";

    vm-profile = {
      url = "github:dmitriiStepanidenko/my-proxmox-vm-profile-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =  {
    vm-profile,
    nixos-generators,
    ...
  }: let
    system = "x86_64-linux";
  in {
    packages.${system} = {
      proxmox = nixos-generators.nixosGenerate {
        inherit system;
        modules = [
          vm-profile.nixosModules.default
        ];
        format = "proxmox";
      };
    };
  };
}
