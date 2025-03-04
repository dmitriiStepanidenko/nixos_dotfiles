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
  environment.systemPackages = [pkgs.ssh-askpass-fullscreen];
  programs.ssh = {
    #enable = true;
    startAgent = true;

    enableAskPassword = true;
    askPassword = "${pkgs.ssh-askpass-fullscreen}/bin/ssh-askpass-fullscreen";

    extraConfig = ''
      AddKeysToAgent yes
    '';
  };
  # TODO: automate copy of pub files to .ssh
}
