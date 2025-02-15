{
  config,
  pkgs,
  sops,
  ...
}: {
  sops.secrets."xray_config.json" = {
    owner = config.users.users.xray.name;
    mode = "0400";
  };

  environment.systemPackages = with pkgs; [
    xray
  ];
  services.xray = {
    enable = true;
    settingsFile = config.sops.secrets."xray_config.json".path;
  };
  systemd.services.xray = {
    serviceConfig = {
      User = config.users.users.xray.name;
      LogsDirectory = "xray";
    };
  };
  networking.proxy = {
    default = "socks5://127.0.0.1:10808";
  };

  environment.variables = {
    #HTTP_PROXY = "socks5://127.0.0.1:10808";
    HTTPS_PROXY = "socks5://127.0.0.1:10808";
  };
  users.users.xray = {
    isSystemUser = true;
    description = "xray service user";
    group = "xray";
  };
  users.groups.xray = {};
}
