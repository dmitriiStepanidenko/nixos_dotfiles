{
  pkgs,
  lib,
  ...
}: {
  systemd.user.services.sops-nix = {
    Service = {
      ExecStartPre = [
        # Prevents this error on startup:
        # GDBus.Error:org.freedesktop.DBus.Error.ServiceUnknown: The name org.freedesktop.Notifications was not provided by any .service files
        "${pkgs.writeShellScript "sops-nix-start-pre-wait-for-notifications" ''
          if [ -z "$(${lib.getExe pkgs.yubikey-manager} list)" ]; then
            until ${pkgs.systemd}/bin/busctl --user list \
              | ${lib.getExe pkgs.ripgrep} -q org.freedesktop.Notifications; do
              ${pkgs.coreutils}/bin/sleep 1
            done
          fi
        ''}"
        # Make sure to wait for the YubiKey insertion before starting the service
        "${pkgs.writeShellScript "sops-nix-start-pre" ''
          if [ -z "$(${lib.getExe pkgs.yubikey-manager} list)" ]; then
            ${lib.getExe pkgs.libnotify} --urgency=critical --wait 'SOPS-Nix' 'Insert YubiKey to mount secrets...'
            if [ -z "$(${lib.getExe pkgs.yubikey-manager} list)" ]; then
              exit 1
            fi
          fi
        ''}"
      ];
      Environment = lib.mkForce "DBUS_SESSION_BUS_ADDRESS=unix:path=%t/bus";

      Restart = "on-failure";
      RestartSec = "10s";
    };
    Unit = let
      deps = [
        "dbus-user-session.service"
        "graphical-session.target"
        "gpg-agent.socket"
        "pcscd.socket"
      ];
    in {
      Wants = deps;
      After = deps;
    };
  };
}
