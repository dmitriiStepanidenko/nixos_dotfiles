{config, ...}: let
  port = 8888;
  dataDir = "/var/lib/restic";
in {
  config = {
    firewall = {
      interfaces.wg0 = {
        allowedUDPPorts = [
          port
        ];
        allowedTCPPorts = [
          port
        ];
      };
      enable = true;
    };
    services.restic.server = {
      enable = true;
      listenAddress = port;
      inherit dataDir; # tmpFiles does not needed. Restic hadles that
    };
  };
}
