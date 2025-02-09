{
  config,
  pkgs,
  inputs,
  ...
}: {
  # Virtual Box
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = ["dmitrii"];
  virtualisation.virtualbox.host.enableExtensionPack = true;
  #virtualisation.virtualbox.guest.enable = true;
  #virtualisation.virtualbox.guest.draganddrop = true;

  # Libvirt
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
}
