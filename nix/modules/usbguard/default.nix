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
        #owner = config.users.users.systemd-network.name;
        #mode = "0400";
        restartUnits = ["usbguard.service"];
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
