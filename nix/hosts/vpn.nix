{
  config,
  pkgs,
  modulesPath,
  lib,
  system,
  ...
}: {
  config = {
    #Provide a default hostname
    networking.hostName = "vpn";
  };
}
