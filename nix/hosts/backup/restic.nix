{config, ...}: let
  port = 8888;
  listenAddress = "${toString port}";
  dataDir = "/var/lib/restic";
in {
  config = {
    networking.firewall = {
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
      inherit listenAddress;
      inherit dataDir; # tmpFiles does not needed. Restic hadles that
      privateRepos = false;
      htpasswd-file = config.sops.secrets."restic/htpasswd-file".path;
      extraFlags = [
      ];
    };
    sops.secrets = {
      "restic/htpasswd-file" = {
        owner = "restic";
        mode = "0400";
        restartUnits = ["restic-rest-server.service"];
      };
    };
  };
}
