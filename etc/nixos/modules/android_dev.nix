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
      android_sdk.accept_license = true;
    };
  };
  inherit (unstable) android-studio;
in {
  nixpkgs.config.android_sdk.accept_license = true;
  #android_sdk.accept_license = true;
  environment.systemPackages = [
    android-studio
  ];

  home-manager.users.dmitrii = {
    xdg = {
      desktopEntries.android-studio = {
        name = "Android Studio";
        comment = "The official IDE for Android development";
        exec = "${android-studio}/bin/android-studio %f";
        icon = "${android-studio}/share/pixmaps/android-studio.png";
        terminal = false;
        categories = ["Development" "IDE"];
        mimeType = ["application/x-android-studio-project" "Applications/Android Studio" "Applications/Android Studio.app"];
        startupNotify = true;
        settings = {
          StartupWMClass = "jetbrains-studio";
        };
      };
    };
  };
  #environment.etc."applications/android-studio.desktop".text = ''
  #  [Desktop Entry]
  #  Version=1.0
  #  Type=Application
  #  Name=Android Studio
  #  Comment=The official IDE for Android development
  #  Exec=${pkgs.android-studio}/bin/android-studio %f
  #  Icon=${pkgs.android-studio}/share/pixmaps/android-studio.png
  #  Terminal=false
  #  StartupWMClass=jetbrains-studio
  #  Categories=Development;IDE;
  #  MimeType=application/x-android-studio-project;
  #  StartupNotify=true
  #'';

  programs.adb.enable = true;

  users.extraGroups.kvm.members = ["dmitrii"];
  users.extraGroups.adbusers.members = ["dmitrii"];
}
