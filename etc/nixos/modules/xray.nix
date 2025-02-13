{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    xray
  ];
  services.xray = {
    enable = true;
    settingsFile = config.sops.secrets."xray_config.json".path;
    #settingsFile = "/etc/xray/config.json";
  };
  systemd.services.xray = {
    serviceConfig = {
      #LoadCredential = "xray_config.json:${config.sops.secrets."xray_config.json".path}";
      #BindPaths = "${config.sops.secrets."xray_config.json".path}:/etc/xray/config.json:ro";
      User = config.users.users.xray.name;
      LogsDirectory = "xray";
    };
  };
  networking.proxy = {
    #httpsProxy = "socks5h://localhost:10808";
    default = "socks5://127.0.0.1:10808";
  };
  #systemd.services.nix-daemon.environment = {
  #  # socks5h mean that the hostname is resolved by the SOCKS server
  #  https_proxy = "socks5h://localhost:10808";
  #  # https_proxy = "http://localhost:7890"; # or use http prctocol instead of socks5
  #};

  environment.variables = {
    HTTP_PROXY = "socks5://127.0.0.1:10808";
    HTTPS_PROXY = "socks5://127.0.0.1:10808";
  };
  users.users.xray = {
    isSystemUser = true;
    description = "xray service user";
    group = "xray";
  };
  users.groups.xray = {};
}
