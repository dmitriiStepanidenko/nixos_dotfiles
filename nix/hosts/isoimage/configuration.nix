{
  pkgs,
  modulesPath,
  system,
  sops-nix,
  vm-profile,
  ...
}: {
  imports = [
    sops-nix.nixosModules.sops
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    vm-profile.nixosModules.default
  ];
  nixpkgs.hostPlatform = system;
}
