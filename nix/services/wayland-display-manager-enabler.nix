{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.display-manager-enabler;

  # Script to check displays and enable internal if needed
  displayScript = pkgs.writeShellScript "enable-internal-display.sh" ''
    #!/bin/sh

    # Wait a bit for display system to settle
    sleep 2

    # Get the list of connected outputs
    CONNECTED_OUTPUTS=$(${pkgs.wlr-randr}/bin/wlr-randr | grep -B 1 "^  Connected: yes" | grep "^[A-Z]" | awk '{print $1}')

    # Get the internal display name (usually eDP-1 or similar)
    INTERNAL_DISPLAY=$(${pkgs.wlr-randr}/bin/wlr-randr | grep -E "^(eDP|LVDS)" | head -n 1 | awk '{print $1}')

    # If no internal display found, exit
    if [ -z "$INTERNAL_DISPLAY" ]; then
      echo "No internal display found"
      exit 0
    fi

    # Count number of connected displays
    DISPLAY_COUNT=$(echo "$CONNECTED_OUTPUTS" | wc -l)

    # If no external displays are connected, enable the internal display
    if [ "$DISPLAY_COUNT" -le 1 ]; then
      echo "No external displays detected, enabling internal display $INTERNAL_DISPLAY"
      ${pkgs.wlr-randr}/bin/wlr-randr --output "$INTERNAL_DISPLAY" --on
    else
      echo "External displays connected, no action needed"
    fi
  '';
in {
  options.services.display-manager-enabler = {
    enable = mkEnableOption "Display manager enabler for Wayland";

    user = mkOption {
      type = types.str;
      description = "User for which to run the display manager enabler";
      default = "1000";
      example = "alice";
    };
  };

  config = mkIf cfg.enable {
    # Create a systemd service
    systemd.user.services.display-manager-enabler = {
      description = "Wayland Display Manager enabler";

      # Run after resume from sleep and when udev detects display changes
      wantedBy = ["graphical-session.target"];
      partOf = ["graphical-session.target"];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${displayScript}";
        User = cfg.user;
        Restart = "no";
      };
    };

    # Create udev rules to trigger the service when displays are connected/disconnected
    services.udev.extraRules = ''
      ACTION=="change", SUBSYSTEM=="drm", RUN+="${pkgs.systemd}/bin/systemctl --user start display-manager-enabler.service"
    '';

    # Create systemd sleep hook to trigger the service after waking from sleep
    systemd.services.display-manager-enabler-sleep = {
      description = "Trigger display manager enabler after sleep";
      wantedBy = ["sleep.target"];
      after = ["sleep.target"];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.systemd}/bin/systemctl --user start display-manager-enabler.service";
        User = cfg.user;
      };
    };
  };
}
