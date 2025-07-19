{
  lib,
  configLib,
  pkgs,
  ...
}: let
  pathtokeys = "../../etc/nixos/keys/users";
  yubikeys =
    lib.lists.forEach (builtins.attrNames (builtins.readDir pathtokeys))
    (key: lib.substring 0 (lib.stringLength key - lib.stringLength ".pub") key);
  yubikeyPublicKeyEntries = lib.attrsets.mergeAttrsList (
    lib.lists.map
    (key: {".ssh/${key}.pub".source = "${pathtokeys}/${key}.pub";})
    yubikeys
  );
in {
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
    enableSSHSupport = lib.mkDefault false;
  };
  environment.systemPackages = [
    pkgs.ssh-askpass-fullscreen
    pkgs.gnupg
    pkgs.pinentry-curses
  ];
  programs.ssh = {
    startAgent = lib.mkDefault true;

    #enableAskPassword = true;
    askPassword = "${pkgs.ssh-askpass-fullscreen}/bin/ssh-askpass-fullscreen";

    extraConfig = ''
      AddKeysToAgent yes
      ServerAliveInterval 15
      ServerAliveCountMax 240
    '';
  };
  # TODO: automate copy of pub files to .ssh
}
