{
  config,
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
  config = {
    networking.firewall = {
      allowedUDPPorts = [
        4000
      ];
      allowedTCPPorts = [
        4000
      ];
    };
    services.uptime-kuma = {
      enable = true;
      package = unstable.uptime-kuma;
      settings = {
        PORT = "4000";
        HOST = "0.0.0.0";
        NOTIFICATION_PROXY = "socks5://172.16.25.1:1080";
      };
    };
  };
}
