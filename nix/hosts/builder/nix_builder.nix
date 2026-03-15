{ config, pkgs, ... }:
{
  users.users.nixremote = {
    isSystemUser = true;
    group = "nixremote";
    useDefaultShell = true;  # Optional but convenient
    openssh.authorizedKeys.keyFiles = [ ./nix-remote-builder.pub ];  # Copy the .pub file here
  };

  users.groups.nixremote = {};

  nix.settings.trusted-users = [ "nixremote" "dmitrii"];  # Required so the user can build
}
