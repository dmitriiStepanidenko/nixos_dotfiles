# Apps and Packages for android development
{
  config,
  pkgs,
  inputs,
  ...
}: let
  unstable = import inputs.nixos-unstable {
    system = "x86_64-linux";
    config = {
      allowUnfree = true;
    };
  };
in {
  nixpkgs.config.android_sdk.accept_license = true;
  #android_sdk.accept_license = true;
  environment.systemPackages = [
    pkgs.android-studio
  ];

  users.extraGroups.kvm.members = ["dmitrii"];
}
