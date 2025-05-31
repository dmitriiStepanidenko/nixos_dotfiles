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

    DISPLAY_COUNT=$(${pkgs.wlr-randr}/bin/wlr-randr | grep -E "Enabled:\s*yes" | wc -l)

    # Get the internal display name (usually eDP-1 or similar)
    INTERNAL_DISPLAY=$(${pkgs.wlr-randr}/bin/wlr-randr | grep -E "^(eDP|LVDS)" | head -n 1 | awk '{print $1}')

    # If no internal display found, exit
    if [ -z "$INTERNAL_DISPLAY" ]; then
      echo "No internal display found"
      exit 0
    fi

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
      example = "alice";
    };
  };

  config = mkIf cfg.enable {
    # Create a systemd service for the user session
    systemd.user.services.display-manager-enabler = {
      description = "Wayland Display Manager Enabler";

      # Run after resume from sleep and when udev detects display changes
      wantedBy = ["graphical-session.target"];
      partOf = ["graphical-session.target"];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${displayScript}";
        # No User directive in user services
      };
    };

    # Create a systemd path unit to watch for changes in display configuration
    systemd.user.paths.display-manager-enabler = {
      description = "Watch for display changes";
      wantedBy = ["graphical-session.target"];
      pathConfig = {
        PathChanged = ["/sys/class/drm/"];
      };
      unitConfig = {
        OnActiveSec = "2";
      };
    };

    # Create a systemd service for system-level sleep hooks
    systemd.services.display-manager-enabler-sleep = {
      description = "Trigger display manager enabler after sleep";
      wantedBy = ["sleep.target"];
      after = ["sleep.target"];

      script = ''
        # Get the user ID for the specified user
        USER_ID=$(id -u ${cfg.user})

        # Check if the user is logged in
        if [ -n "$(${pkgs.systemd}/bin/loginctl list-users | grep $USER_ID)" ]; then
          # Use machinectl to run the command as the user
          ${pkgs.systemd}/bin/machinectl shell ${cfg.user}@ /run/current-system/sw/bin/systemctl --user start display-manager-enabler.service
        fi
      '';

      serviceConfig = {
        Type = "oneshot";
      };
    };

    # Create udev rules to trigger the service when displays are connected/disconnected
    #services.udev.extraRules = ''
    #  ACTION=="change", SUBSYSTEM=="drm", RUN+="${pkgs.bash}/bin/bash -c 'export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u ${cfg.user})/bus; ${pkgs.systemd}/bin/systemctl --user -M ${cfg.user}@ start display-manager-enabler.service'"
    #'';
  };
}
