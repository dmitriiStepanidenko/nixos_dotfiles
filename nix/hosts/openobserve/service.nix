{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.openobserve;
in {
  options.services.openobserve = {
    enable = mkEnableOption "openobserve service";

    package = mkOption {
      type = types.package;
      default = pkgs.openobserve;
      description = "Openobserve package to use";
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/openobserve";
      description = "Directory to store openobserve files";
    };
    user = mkOption {
      type = types.str;
      default = "openobserve";
      description = "User permissionss of this service";
    };
    group = mkOption {
      type = types.str;
      default = "openobserve";
      description = "Group permissionss of this service";
    };
    rootUser = {
      email = mkOption {
        type = types.path;
        description = "Path to root user email";
      };
      password = mkOption {
        type = types.path;
        description = "Path to root user password";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' 0750 ${cfg.user} ${cfg.group} - -"
    ];
    systemd.services.openobserve = {
      description = "openobserve service";
      wantedBy = ["multi-user.target"];
      after = ["network-online.target" "nss-lookup.target"];
      wants = ["network-online.target" "nss-lookup.target"];

      serviceConfig = {
        Restart = "always";
        RestartSec = "7";
        User = cfg.user;
        Group = cfg.group;

        WorkingDirectory = cfg.dataDir;
      };
      script = ''
        ZO_DATA_DIR=${toString cfg.dataDir} \
        ZO_ROOT_USER_EMAIL=$(cat ${cfg.rootUser.email}) \
        ZO_ROOT_USER_PASSWORD=$(cat ${cfg.rootUser.password}) \
        ${cfg.package}/bin/openobserve
      '';
    };
    users.users."${cfg.user}" = {
      isSystemUser = true;
      inherit (cfg) group;
      #home = cfg.dataDir;
      #createHome = true;
      description = "openobserve service user";
    };
    users.groups."${cfg.group}" = {};
  };
}
