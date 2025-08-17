{
  pkgs,
  config,
  ...
}
: {
  config = {
    sops = {
      secrets."usbguard/rule_file" = {
        sopsFile = ./secrets.yaml;
      };
    };
    services.usbguard = {
      enable = true;
      dbus.enable = true;
      IPCAllowedUsers = [
        "root"
        "dmitrii"
      ];
      ruleFile = config.sops.secrets."usbguard/rule_file".path;
    };
  };
}
