{
  inputs,
  config,
  pkgs,
  ...
}: let
  startupScript = pkgs.pkgs.writeShellScriptBin "start" ''
    ${pkgs.waybar}/bin/waybar 2>&1 > ~/waybar.log &
    ${pkgs.swww}/bin/swww init 2>&1 > ~/swww_init.log &

    sleep 1

    ${pkgs.swww}/bin/swww img ${../../../images/wanderer.jpg}
  '';
  hyprlandPkg = inputs.hyprland.packages."${pkgs.system}".hyprland;
  backgroundImage = ../../../images/wanderer.jpg;
  girlImage = ../../../images/wallpaper.jpg;
  girlImageBackgroundColor = "676570";
  animatedImage = ../../../images/anime-girl-wearing-a-hoodie.1920x1080.gif;
  wallpaperCmd = "${pkgs.swww}/bin/swww img ${girlImage} --resize fit --fill-color ${girlImageBackgroundColor} 2>&1 > \${XDG_LOG_DIR:-/home/dmitrii/logs}/swww.log";
  sessionLockCommand = "${pkgs.swaylock}/bin/swaylock -e -d -i ${girlImage} -s fit -c ${girlImageBackgroundColor}";
  sessionLockCommandPidof = "pidof swaylock || ${sessionLockCommand}";
  sessionLockCommandWithLog = "${sessionLockCommandPidof} &> $XDG_LOG_DIR/swaylock.log";
  sessionLockCommandPkill = "pkill -x swaylock; ${sessionLockCommand}";
  sessionLockDispatchCommand = "${hyprlandPkg}/bin/hyprctl dispatch exec \"${sessionLockCommandPkill}\"";
  #sessionLockDispatchCommand = sessionLockCommand;
  conditionalSuspendScript = pkgs.writeShellScript "conditional-suspend" ''
    # Check multiple conditions for NVIDIA presence
    nvidia_present=false

    # Check if NVIDIA GPU is present in lspci
    if lspci | grep -i nvidia > /dev/null 2>&1; then
      nvidia_present=true
    fi

    # Check if NVIDIA kernel modules are loaded
    if lsmod | grep -i nvidia > /dev/null 2>&1; then
      nvidia_present=true
    fi

    # Check if nvidia device files exist
    if [ -e /dev/nvidia0 ]; then
      nvidia_present=true
    fi

    if [ "$nvidia_present" = true ]; then
      echo "NVIDIA GPU detected/enabled, using NOTHING instead of hibernation"
      #systemctl suspend
      #systemctl hibernate
    else
      echo "No NVIDIA GPU detected/enabled, safe to suspend/hibernate"
      #systemctl suspend
    fi
  '';

  swaylockRestartText = instance: ''
    pidof swaylock || pkill -x swaylock
    echo "Pidof swaylock\pkill ended"
    echo "Using Hyprland instance: ${instance}"
    ${hyprlandPkg}/bin/hyprctl --instance ${instance} 'keyword misc:allow_session_lock_restore 1'
    echo "Allowed session restore"
    ${hyprlandPkg}/bin/hyprctl --instance ${instance} dispatch exec "${sessionLockCommand}"
    echo "Dispatched new lock"
  '';
  swaylockRestartBin = pkgs.writeShellScriptBin "swaylock_restart" ''
    INSTANCE=''${1:-0}
    echo "Using Hyprland instance: $INSTANCE"
    ${swaylockRestartText "$INSTANCE"}
  '';

  wallpaperRestartBin = pkgs.writeShellScriptBin "wallpaper" ''
    ${wallpaperCmd}
  '';
in {
  imports = [
    ./waybar.nix
  ];
  home.packages = with pkgs; [
    swaylockRestartBin
    wallpaperRestartBin
  ];

  xdg.enable = true;
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    extraConfig = {
      XDG_LOG_DIR = "${config.home.homeDirectory}/logs";
    };
  };
  wayland.windowManager.hyprland = {
    enable = true;
    #package = inputs.hyprland.packages."${pkgs.system}".hyprland;
    #portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
    package = null;
    portalPackage = null;
    xwayland.enable = true;
    settings = {
      #exec-once = ''${startupScript}/bin/start'';
      #general = {
      #lock_cmd = "pidof hyprlock || hyprlock"; # avoid starting multiple hyprlock instances.
      #before_sleep_cmd = "loginctl lock-session"; # lock before suspend.
      #after_sleep_cmd = "hyprctl dispatch dpms on"; # to avoid having to press a key twice to turn on the display.
      #};
      misc = {
        render_unfocused_fps = 20;
      };
      input = {
        kb_layout = "us,ru";
        kb_variant = "";
        kb_options = "grp:win_space_toggle";
      };
      exec-once = [
        "sleep 2;  pkill waybar; ${pkgs.waybar}/bin/waybar 2>&1 > $XDG_LOG_DIR/waybar.log"
        #"${pkgs.swww}/bin/swww init 2>&1 > ~/swww_init.log &"
        #"${pkgs.swww}/bin/swww img ${animatedImage} --resize fit --fill-color 66636E 2>&1 > ~/swww.log"
        wallpaperCmd
        "${pkgs.hypridle}/bin/hypridle 2>&1 > $XDG_LOG_DIR/hypridle.log"
      ];
      "$terminal" = "alacritty";
      "$mod" = "SUPER";
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
      windowrule = [
        # stopped working after update. TODO: investigate in future
        #"renderunfocused, title:(.*(k|K)enshi.*)"
      ];
      bind =
        [
          "$mod, F, exec, firefox"
          "$mod, P, exec, ${pkgs.wofi}/bin/wofi --show run --xoffset=20 --yoffset=12 --width=220px --height=620 --term=footclient --prompt=Run"
          "$mod, RETURN, exec, alacritty"
          "$mod, Q, killactive"

          "$mod, H, movefocus, l"
          "$mod, L, movefocus, r"
          "$mod, K, movefocus, u"
          "$mod, J, movefocus, d"
          "$mod SHIFT, H, movewindow, l"
          "$mod SHIFT, L, movewindow, r"
          "$mod SHIFT, K, movewindow, u"
          "$mod SHIFT, J, movewindow, d"

          "$mod CONTROL, H, resizeactive, -40 0"
          "$mod CONTROL, L, resizeactive, 40 0"
          "$mod CONTROL, K, resizeactive, 0 -40"
          "$mod CONTROL, J, resizeactive, 0 40"

          "$mod SHIFT, S, exec, ${pkgs.hyprshot}/bin/hyprshot -m region --clipboard-only"

          "CONTROL SHIFT, L, exec, ${sessionLockCommandWithLog}"

          ",XF86MonBrightnessUp,exec,${pkgs.brightnessctl}/bin/brightnessctl set +5%"
          ",XF86MonBrightnessDown,exec,${pkgs.brightnessctl}/bin/brightnessctl set 5%-"
          ",XF86AudioRaiseVolume,exec, ${pkgs.pamixer}/bin/pamixer -i 5"
          ",XF86AudioLowerVolume,exec, ${pkgs.pamixer}/bin/pamixer -d 5"
          ",XF86AudioMute,exec, ${pkgs.pamixer}/bin/pamixer -t"

          "$mod, code:19, workspace, 10"
          "$mod SHIFT, code:19, movetoworkspace, 10"
        ]
        ++ (
          # workspaces
          # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
          builtins.concatLists (builtins.genList (
              i: let
                ws = i + 1;
              in [
                "$mod, code:1${toString i}, workspace, ${toString ws}"
                "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
              ]
            )
            9)
        );
    };
  };
  programs.hyprlock = {
    enable = false;
    package = null;
    #package = inputs.hyprlock.packages."${pkgs.system}".hyprlock;
    settings = {
      general = {
        grace = 300;
        hide_cursor = true;
      };
      background = [
        {
          path = "${backgroundImage}";
          blur_passes = 3;
          blur_size = 8;
        }
      ];
      input-field = [
        {
          size = "200, 50";
          position = "0, -80";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          font_color = "rgb(202, 211, 245)";
          inner_color = "rgb(91, 96, 120)";
          outer_color = "rgb(24, 25, 38)";
          outline_thickness = 5;
          placeholder_text = "Password...";
          shadow_passes = 2;
        }
      ];
    };
  };
  programs.swaylock = {
    enable = true;
    settings = {
      color = "808080";
      font-size = 24;
      indicator-idle-visible = false;
      indicator-radius = 100;
      line-color = "ffffff";
      show-failed-attempts = true;
    };
  };
  services.swaync.enable = true;
  services.swww.enable = true;
  services.swayidle = {
    enable = false;
  };
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        after_sleep_cmd = "${hyprlandPkg}/bin/hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
        #lock_cmd = "${pkgs.swaylock}/bin/swaylock -fF";
        lock_cmd = sessionLockDispatchCommand;
        before_sleep_cmd = sessionLockDispatchCommand;
      };
      listener = [
        {
          timeout = 6 * 60;
          #on-timeout = "${pkgs.swaylock}/bin/swaylock -fF";
          on-timeout = sessionLockDispatchCommand;
        }
        #{
        #  timeout = 20 * 60;
        #  on-timeout = "hyprctl dispatch dpms off";
        #  on-resume = "hyprctl dispatch dpms on";
        #}
        {
          timeout = 36 * 60;
          on-timeout = "${conditionalSuspendScript}";
          on-resume = "${wallpaperCmd}";
        }
      ];
    };
  };
  services.kanshi = let
    internal = "INTERNAL";
    docked_home = "DOCKED_HOME";
  in {
    enable = true;
    settings = [
      {
        output = {
          alias = internal;
          criteria = "eDP-1";
        };
      }
      {
        output = {
          alias = docked_home;
          mode = "3440x1440@99.98200Hz";
          criteria = "Huawei Technologies Co., Inc. ZQE-CAA 0xC080F622";
          scale = 1.0;
        };
      }
      {
        profile = {
          name = "docked";
          exec = [
            "sleep 3 && ${swaylockRestartBin}/bin/swaylock_restart"
            "sleep 3 && ${wallpaperRestartBin}/bin/wallpaper"
          ];
          outputs = [
            {
              criteria = "\$${internal}";
              status = "disable";
            }
            {
              criteria = "\$${docked_home}";
              status = "enable";
            }
          ];
        };
      }
      {
        profile = {
          name = "undocked";
          exec = [
            "sleep 3 && ${swaylockRestartBin}/bin/swaylock_restart"
            "sleep 3 && ${wallpaperRestartBin}/bin/wallpaper"
          ];
          outputs = [
            {
              criteria = "\$${internal}";
              status = "enable";
            }
          ];
        };
      }
    ];
  };
}
