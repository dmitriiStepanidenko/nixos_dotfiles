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
  backgroundImage = ../../../images/wanderer.jpg;
  girlImage = ../../../images/wallpaper.jpg;
  girlImageBackgroundColor = "676570";
  animatedImage = ../../../images/anime-girl-wearing-a-hoodie.1920x1080.gif;
  wallpaperCmd = "${pkgs.swww}/bin/swww img ${girlImage} --resize fit --fill-color ${girlImageBackgroundColor} 2>&1 > $XDG_LOG_DIR/swww.log";
  sessionLockCommand = "pidof swaylock || ${pkgs.swaylock}/bin/swaylock -f -i ${girlImage} -s fit -c ${girlImageBackgroundColor}";
  sessionLockCommandWithLog = "${sessionLockCommand} &> $XDG_LOG_DIR/swaylock.log";
  sessionLockDispatchCommand = "hyprctl dispatch exec \"${sessionLockCommand}\"";
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
    if [ -e /dev/nvidia0 ] || [ -e /dev/nvidiactl ]; then
      nvidia_present=true
    fi

    if [ "$nvidia_present" = true ]; then
      echo "NVIDIA GPU detected/enabled, using NOTHING instead of hibernation"
      #systemctl suspend
      #systemctl hibernate
    else
      echo "No NVIDIA GPU detected/enabled, safe to hibernate"
      systemctl hibernate
    fi
  '';
in {
  imports = [
    ./waybar.nix
  ];
  home.packages = with pkgs; [
    (
      writeShellScriptBin "swaylock_restart" ''
        hyprctl --instance 0 'keyword misc:allow_session_lock_restore 1'
        hyprctl --instance 0 '${sessionLockCommand}'
      ''
    )
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
        "renderunfocused, title:(.*(k|K)enshi.*)"
        #"noinitialfocus,class:(kenshi_x64.exe)"
        #"nofocus,class:(kenshi_x64.exe)"
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
  #programs.waybar = {
  #  enable = true;
  #  style = ''
  #    #waybar {
  #        font-family: "SF Pro Display", Cantarell, Noto Sans, sans-serif;
  #        font-size: 16px;
  #    }
  #    #window {
  #        padding: 0 10px;
  #    }
  #    window#waybar {
  #        border: none;
  #        border-radius: 0;
  #        box-shadow: none;
  #        text-shadow: none;
  #        transition-duration: 0s;
  #        color: rgba(217, 216, 216, 1);
  #        background: #1a1b26;
  #    }
  #    #workspaces {
  #        margin: 0 2px;
  #    }
  #    #workspaces button {
  #        padding: 0 8px;
  #        color: #565f89;
  #        border: 3px solid rgba(9, 85, 225, 0);
  #        border-radius: 10px;
  #        min-width: 33px;
  #    }
  #    #workspaces button.visible {
  #        color: #a9b1d6;
  #    }
  #    #workspaces button.focused {
  #        border-top: 3px solid #7aa2f7;
  #        border-bottom: 3px solid #7aa2f7;
  #    }
  #    #workspaces button.urgent {
  #        background-color: #a96d1f;
  #        color: white;
  #    }
  #    #workspaces button:hover {
  #        box-shadow: inherit;
  #        border-color: #bb9af7;
  #        color: #bb9af7;
  #    }
  #    /* Repeat style here to ensure properties are overwritten as there's no !important and button:hover above resets the colour */
  #    #workspaces button.focused {
  #        color: #7aa2f7;
  #    }
  #    #workspaces button.focused:hover {
  #        color: #bb9af7;
  #    }
  #    #pulseaudio {
  #        /* font-size: 26px; */
  #    }
  #    #custom-recorder {
  #    	font-size: 18px;
  #    	margin: 2px 7px 0px 7px;
  #    	color:#ee2e24;
  #    }
  #    #tray,
  #    #mode,
  #    #battery,
  #    #temperature,
  #    #cpu,
  #    #mpd,
  #    #mpris,
  #    #privacy,
  #    #bluetooth,
  #    #memory,
  #    #network,
  #    #pulseaudio,
  #    #wireplumber,
  #    #idle_inhibitor,
  #    #hyprland-language,
  #    #language,
  #    #backlight,
  #    #custom-storage,
  #    #custom-cpu_speed,
  #    #custom-powermenu,
  #    #custom-spotify,
  #    #custom-weather,
  #    #custom-mail,
  #    #custom-media {
  #        margin: 0px 0px 0px 10px;
  #        padding: 0 5px;
  #        /* border-top: 3px solid rgba(217, 216, 216, 0.5); */
  #    }
  #    /* #clock {
  #        margin:     0px 16px 0px 10px;
  #        min-width:  140px;
  #    } */
  #    #battery.warning {
  #        color: rgba(255, 210, 4, 1);
  #    }
  #    #battery.critical {
  #        color: rgba(238, 46, 36, 1);
  #    }
  #    #battery.charging {
  #        color: rgba(217, 216, 216, 1);
  #    }
  #    #custom-storage.warning {
  #        color: rgba(255, 210, 4, 1);
  #    }
  #    #custom-storage.critical {
  #        color: rgba(238, 46, 36, 1);
  #    }
  #    @keyframes blink {
  #        to {
  #            background-color: #ffffff;
  #            color: black;
  #        }
  #    }
  #  '';
  #  settings = {
  #    mainBar = {
  #      layer = "top";
  #      position = "top";
  #      height = 30;
  #      #output = [
  #      #      "eDP-1"
  #      #      "HDMI-A-1"
  #      #    ];
  #      modules-left = ["hyprland/workspaces" "wlr/taskbar" "hyprland/window"];
  #      modules-center = ["clock" "hyprland/language" "battery" "temperature"];
  #      modules-right = ["mpris" "network" "privacy" "pulseaudio" "bluetooth" "backlight" "cpu" "memory"];

  #      "hyprland/workspaces" = {
  #        disable-scroll = true;
  #        all-outputs = false;
  #        warp-on-scroll = false;
  #        format = "{name}: {icon}";
  #        show-special = true;
  #        persistent-workspaces = {
  #          "1" = [];
  #          "2" = [];
  #          "3" = [];
  #          "4" = [];
  #          "5" = [];
  #          "6" = [];
  #          "7" = [];
  #          "8" = [];
  #          "9" = [];
  #          "10" = [];
  #        };
  #        format-icons = {
  #          "1" = "<span font='Font Awesome 5 Free 14'></span>";
  #          "2" = "<span font='Font Awesome 5 Free 14'></span>";
  #          "3" = "<span font='Font Awesome 5 Free 14'></span>";
  #          "4" = "<span font='Font Awesome 5 Free 14'></span>";
  #          "5" = "<span font='Font Awesome 5 Free 14'></span>";
  #          "6" = "<span font='Font Awesome 5 Free 14'></span>";
  #          "7" = "<span font='Font Awesome 5 Free 14'></span>";
  #          "8" = "<span font='Font Awesome 5 Free 14'></span>";
  #          "9" = "<span font='Font Awesome 5 Free 14'></span>";
  #          "10" = "<span font='Font Awesome 5 Free 14'></span>";
  #          urgent = " ";
  #          active = " ";
  #          default = " ";
  #        };
  #      };
  #      "hyprland/window" = {
  #      };
  #      network = {
  #        #interface = "wlp2s0";
  #        format = "{ifname}";
  #        format-wifi = "{essid} ({signalStrength}%) ";
  #        format-ethernet = "{ipaddr}/{cidr} 󰊗";
  #        format-disconnected = ""; #An empty format will hide the module.
  #        tooltip-format = "{ifname} via {gwaddr} 󰊗";
  #        tooltip-format-wifi = "{essid} ({signalStrength}%) ";
  #        tooltip-format-ethernet = "{ifname} ";
  #        tooltip-format-disconnected = "Disconnected";
  #        max-length = 50;
  #      };
  #      mpris = {
  #        format = "{player_icon} {dynamic}";
  #        format-paused = "{status_icon} <i>{dynamic}</i>";
  #        dynamic-len = 40;
  #        dynamic-importance-order = ["title" "position" "artist" "album" "length"];
  #        player-icons = {
  #          default = "▶";
  #          mpv = "🎵";
  #        };
  #        status-icons = {
  #          paused = "⏸";
  #        };
  #        # "ignored-players": ["firefox"]
  #      };
  #      privacy = {
  #        icon-spacing = 2;
  #        icon-size = 18;
  #        transition-duration = 250;
  #        modules = [
  #          {
  #            type = "screenshare";
  #            tooltip = true;
  #            tooltip-icon-size = 24;
  #          }
  #          {
  #            type = "audio-out";
  #            tooltip = true;
  #            tooltip-icon-size = 24;
  #          }
  #          {
  #            type = "audio-in";
  #            tooltip = true;
  #            tooltip-icon-size = 24;
  #          }
  #        ];
  #      };
  #      bluetooth = {
  #        format = " {status}";
  #        format-connected = " {device_alias}";
  #        format-connected-battery = " {device_alias} {device_battery_percentage}%";
  #        #// format-device-preference = [ "device1"; "device2" ], // preference list deciding the displayed device
  #        tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
  #        tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
  #        tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
  #        tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
  #      };
  #      temperature = {
  #        critical-threshold = 85;
  #        format-critical = "{temperatureC}°C ";
  #        format = "{temperatureC}°C ";
  #      };
  #      cpu = {
  #        "format" = "︁  {}%";
  #        tooltip = true;
  #      };
  #      memory = {
  #        format = "<span font='Font Awesome 5 Free 9'>︁</span> {used:0.1f}G/{total:0.1f}G";
  #        tooltip = true;
  #      };
  #      backlight = {
  #        format = "{percent}% {icon}";
  #        format-icons = ["" ""];
  #      };
  #      "hyprland/language" = {
  #        format = "  {}";
  #        format-en = "EN";
  #        format-ru = "RU";
  #      };
  #      battery = {
  #        states = {
  #          warning = 30;
  #          critical = 15;
  #        };
  #        format = "<span font='Font Awesome 5 Free 11'>{icon}</span> {capacity}%{time}";
  #        format-time = " ({H}h{M}m)";
  #        format-full = "<span font='Font Awesome 5 Free'></span>  <span font='Font Awesome 5 Free 11'>{icon}</span>  Charged";
  #        format-charging = "<span font='Font Awesome 5 Free'></span>  <span font='Font Awesome 5 Free 11'>{icon}</span>  {capacity}% - {time}";
  #        format-plugged = "  {capacity}%";
  #        format-alt = "{time}  {icon}";
  #        format-icons = ["" "" "" "" ""];
  #      };
  #      clock = {
  #        format = "{:%H:%M | %e %B} ";
  #        tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
  #        format-alt = "{:%Y-%m-%d}";
  #        tooltrip = true;
  #        calendar = {
  #          mode = "year";
  #          mode-mon-col = 3;
  #          weeks-pos = "right";
  #          on-scroll = 1;
  #          format = {
  #            months = "<span color='#ffead3'><b>{}</b></span>";
  #            days = "<span color='#ecc6d9'><b>{}</b></span>";
  #            weeks = "<span color='#99ffdd'><b>W{}</b></span>";
  #            weekdays = "<span color='#ffcc66'><b>{}</b></span>";
  #            today = "<span color='#ff6699'><b><u>{}</u></b></span>";
  #          };
  #        };
  #        actions = {
  #          on-click-right = "mode";
  #          on-scroll-up = "shift_up";
  #          on-scroll-down = "shift_down";
  #        };
  #      };
  #      pulseaudio = {
  #        "format" = "<span font='Font Awesome 5 Free 11'>{icon:2}</span>{volume}%";
  #        "format-alt" = "<span font='Font Awesome 5 Free 11'>{icon:2}</span>{volume}%";
  #        "format-alt-click" = "click-right";
  #        "format-muted" = "<span font='Font Awesome 5 Free 11'></span>";
  #        "format-icons" = {
  #          "headphone" = "󰋋";
  #          "hands-free" = "";
  #          "headset" = "";
  #          "phone" = "";
  #          "portable" = "";
  #          "car" = "";
  #          "default" = ["󱡫"];
  #        };
  #        "scroll-step" = 2;
  #        "on-click" = "pavucontrol";
  #        "tooltip" = true;
  #      };
  #    };
  #  };
  #};
  services.swaync.enable = true;
  services.swww.enable = true;
  services.swayidle = {
    enable = false;
  };
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        after_sleep_cmd = "hyprctl dispatch dpms on";
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
          timeout = 20 * 60;
          on-timeout = "${conditionalSuspendScript}";
          on-resume = "${wallpaperCmd}";
        }
      ];
    };
  };
  services.kanshi = {
    enable = true;
    profiles = {
      docked = {
        name = "docked";
        outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "HDMI-A-1";
            status = "enable";
          }
        ];
      };
      undocked = {
        name = "undocked";
        outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
          }
        ];
      };
    };
  };
}
