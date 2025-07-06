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
  services.cloud-init.network.enable = true;
  system.stateVersion = "25.05";
}
