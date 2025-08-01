{
  inputs,
  config,
  pkgs,
  ...
}: let
in {
  programs.waybar = {
    enable = true;
    style = ''
      #waybar {
          font-family: "SF Pro Display", Cantarell, Noto Sans, sans-serif;
          font-size: 16px;
      }
      #window {
          padding: 0 10px;
      }
      window#waybar {
          border: none;
          border-radius: 0;
          box-shadow: none;
          text-shadow: none;
          transition-duration: 0s;
          color: rgba(217, 216, 216, 1);
          background: #1a1b26;
      }

      /* Styles for external display */
      window#waybar.external {
          font-size: 16px;
      }

      /* Styles for internal display - smaller font and tighter spacing */
      window#waybar.internal {
          font-size: 14px;
      }

      .internal #workspaces {
          margin: 0 1px;
      }

      .internal #workspaces button {
          padding: 0 4px;
          min-width: 25px;
      }

      .internal #tray,
      .internal #mode,
      .internal #battery,
      .internal #temperature,
      .internal #cpu,
      .internal #mpd,
      .internal #mpris,
      .internal #privacy,
      .internal #bluetooth,
      .internal #memory,
      .internal #network,
      .internal #pulseaudio,
      .internal #wireplumber,
      .internal #idle_inhibitor,
      .internal #hyprland-language,
      .internal #language,
      .internal #backlight,
      .internal #custom-storage,
      .internal #custom-cpu_speed,
      .internal #custom-powermenu,
      .internal #custom-spotify,
      .internal #custom-weather,
      .internal #custom-mail,
      .internal #custom-media {
          margin: 0px 0px 0px 5px;
          padding: 0 3px;
      }

      #workspaces {
          margin: 0 2px;
      }
      #workspaces button {
          padding: 0 8px;
          color: #565f89;
          border: 3px solid rgba(9, 85, 225, 0);
          border-radius: 10px;
          min-width: 33px;
      }
      #workspaces button.visible {
          color: #a9b1d6;
      }
      #workspaces button.focused {
          border-top: 3px solid #7aa2f7;
          border-bottom: 3px solid #7aa2f7;
      }
      #workspaces button.urgent {
          background-color: #a96d1f;
          color: white;
      }
      #workspaces button:hover {
          box-shadow: inherit;
          border-color: #bb9af7;
          color: #bb9af7;
      }
      /* Repeat style here to ensure properties are overwritten as there's no !important and button:hover above resets the colour */
      #workspaces button.focused {
          color: #7aa2f7;
      }
      #workspaces button.focused:hover {
          color: #bb9af7;
      }
      #pulseaudio {
          /* font-size: 26px; */
      }
      #custom-recorder {
      	font-size: 18px;
      	margin: 2px 7px 0px 7px;
      	color:#ee2e24;
      }
      #tray,
      #mode,
      #battery,
      #temperature,
      #cpu,
      #mpd,
      #mpris,
      #privacy,
      #bluetooth,
      #memory,
      #network,
      #pulseaudio,
      #wireplumber,
      #idle_inhibitor,
      #hyprland-language,
      #language,
      #backlight,
      #custom-storage,
      #custom-cpu_speed,
      #custom-powermenu,
      #custom-spotify,
      #custom-weather,
      #custom-mail,
      #custom-media {
          margin: 0px 0px 0px 10px;
          padding: 0 5px;
          /* border-top: 3px solid rgba(217, 216, 216, 0.5); */
      }
      /* #clock {
          margin:     0px 16px 0px 10px;
          min-width:  140px;
      } */
      #battery.warning {
          color: rgba(255, 210, 4, 1);
      }
      #battery.critical {
          color: rgba(238, 46, 36, 1);
      }
      #battery.charging {
          color: rgba(217, 216, 216, 1);
      }
      #custom-storage.warning {
          color: rgba(255, 210, 4, 1);
      }
      #custom-storage.critical {
          color: rgba(238, 46, 36, 1);
      }
      @keyframes blink {
          to {
              background-color: #ffffff;
              color: black;
          }
      }
    '';
    settings = {
      # External display configuration
      externalBar = {
        layer = "top";
        position = "top";
        height = 30;
        output = ["HDMI-A-1"];
        modules-left = ["hyprland/workspaces" "wlr/taskbar" "hyprland/window"];
        modules-center = ["clock" "hyprland/language" "battery" "temperature"];
        modules-right = ["mpris" "network" "privacy" "pulseaudio" "bluetooth" "backlight" "cpu" "memory"];

        "hyprland/workspaces" = {
          disable-scroll = true;
          all-outputs = false;
          warp-on-scroll = false;
          format = "{name}: {icon}";
          show-special = true;
          persistent-workspaces = {
            "1" = [];
            "2" = [];
            "3" = [];
            "4" = [];
            "5" = [];
            "6" = [];
            "7" = [];
            "8" = [];
            "9" = [];
            "10" = [];
          };
          format-icons = {
            "1" = "<span font='Font Awesome 5 Free 14'></span>";
            "2" = "<span font='Font Awesome 5 Free 14'></span>";
            "3" = "<span font='Font Awesome 5 Free 14'></span>";
            "4" = "<span font='Font Awesome 5 Free 14'></span>";
            "5" = "<span font='Font Awesome 5 Free 14'></span>";
            "6" = "<span font='Font Awesome 5 Free 14'></span>";
            "7" = "<span font='Font Awesome 5 Free 14'></span>";
            "8" = "<span font='Font Awesome 5 Free 14'></span>";
            "9" = "<span font='Font Awesome 5 Free 14'></span>";
            "10" = "<span font='Font Awesome 5 Free 14'></span>";
            urgent = " ";
            active = " ";
            default = " ";
          };
        };
        "hyprland/window" = {
        };
        network = {
          #interface = "wlp2s0";
          format = "{ifname}";
          format-wifi = "{essid} ({signalStrength}%) ";
          format-ethernet = "{ipaddr}/{cidr} 󰊗";
          format-disconnected = ""; #An empty format will hide the module.
          tooltip-format = "{ifname} via {gwaddr} 󰊗";
          tooltip-format-wifi = "{essid} ({signalStrength}%) ";
          tooltip-format-ethernet = "{ifname} ";
          tooltip-format-disconnected = "Disconnected";
          max-length = 50;
        };
        mpris = {
          format = "{player_icon} {dynamic}";
          format-paused = "{status_icon} <i>{dynamic}</i>";
          dynamic-len = 40;
          dynamic-importance-order = ["title" "position" "artist" "album" "length"];
          player-icons = {
            default = "▶";
            mpv = "🎵";
          };
          status-icons = {
            paused = "⏸";
          };
          # "ignored-players": ["firefox"]
        };
        privacy = {
          icon-spacing = 2;
          icon-size = 18;
          transition-duration = 250;
          modules = [
            {
              type = "screenshare";
              tooltip = true;
              tooltip-icon-size = 24;
            }
            {
              type = "audio-out";
              tooltip = true;
              tooltip-icon-size = 24;
            }
            {
              type = "audio-in";
              tooltip = true;
              tooltip-icon-size = 24;
            }
          ];
        };
        bluetooth = {
          format = " {status}";
          format-connected = " {device_alias}";
          format-connected-battery = " {device_alias} {device_battery_percentage}%";
          #// format-device-preference = [ "device1"; "device2" ], // preference list deciding the displayed device
          tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
          tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
        };
        temperature = {
          critical-threshold = 85;
          format-critical = "{temperatureC}°C ";
          format = "{temperatureC}°C ";
        };
        cpu = {
          "format" = "︁  {}%";
          tooltip = true;
        };
        memory = {
          format = "<span font='Font Awesome 5 Free 9'>︁</span> {used:0.1f}G/{total:0.1f}G";
          tooltip = true;
        };
        backlight = {
          format = "{percent}% {icon}";
          format-icons = ["" ""];
        };
        "hyprland/language" = {
          format = "  {}";
          format-en = "EN";
          format-ru = "RU";
        };
        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "<span font='Font Awesome 5 Free 11'>{icon}</span> {capacity}%{time}";
          format-time = " ({H}h{M}m)";
          format-full = "<span font='Font Awesome 5 Free'></span>  <span font='Font Awesome 5 Free 11'>{icon}</span>  Charged";
          format-charging = "<span font='Font Awesome 5 Free'></span>  <span font='Font Awesome 5 Free 11'>{icon}</span>  {capacity}% - {time}";
          format-plugged = "  {capacity}%";
          format-alt = "{time}  {icon}";
          format-icons = ["" "" "" "" ""];
        };
        clock = {
          format = "{:%H:%M | %e %B} ";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          format-alt = "{:%Y-%m-%d}";
          tooltrip = true;
          calendar = {
            mode = "year";
            mode-mon-col = 3;
            weeks-pos = "right";
            on-scroll = 1;
            format = {
              months = "<span color='#ffead3'><b>{}</b></span>";
              days = "<span color='#ecc6d9'><b>{}</b></span>";
              weeks = "<span color='#99ffdd'><b>W{}</b></span>";
              weekdays = "<span color='#ffcc66'><b>{}</b></span>";
              today = "<span color='#ff6699'><b><u>{}</u></b></span>";
            };
          };
          actions = {
            on-click-right = "mode";
            on-scroll-up = "shift_up";
            on-scroll-down = "shift_down";
          };
        };
        pulseaudio = {
          "format" = "<span font='Font Awesome 5 Free 11'>{icon:2}</span>{volume}%";
          "format-alt" = "<span font='Font Awesome 5 Free 11'>{icon:2}</span>{volume}%";
          "format-alt-click" = "click-right";
          "format-muted" = "<span font='Font Awesome 5 Free 11'></span>";
          "format-icons" = {
            "headphone" = "󰋋";
            "hands-free" = "";
            "headset" = "";
            "phone" = "";
            "portable" = "";
            "car" = "";
            "default" = ["󱡫"];
          };
          "scroll-step" = 2;
          "on-click" = "pavucontrol";
          "tooltip" = true;
        };
      };

      # Internal display configuration - compact layout
      internalBar = {
        layer = "top";
        position = "top";
        height = 20; # Smaller height for internal display
        output = ["eDP-1"];
        modules-left = ["hyprland/workspaces" "hyprland/window"];
        modules-center = ["clock" "hyprland/language" "temperature"];
        modules-right = ["battery" "network" "pulseaudio" "backlight"]; # Fewer modules for space

        "hyprland/workspaces" = {
          disable-scroll = true;
          all-outputs = false;
          warp-on-scroll = false;
          format = "{icon}"; # Only icon, no name for compact view
          show-special = true;
          persistent-workspaces = {
            "1" = [];
            "2" = [];
            "3" = [];
            "4" = [];
            "5" = [];
            "6" = [];
            "7" = [];
            "8" = [];
            "9" = [];
            "10" = [];
          };
          format-icons = {
            "1" = "<span font='Font Awesome 5 Free 14'></span>";
            "2" = "<span font='Font Awesome 5 Free 14'></span>";
            "3" = "<span font='Font Awesome 5 Free 14'></span>";
            "4" = "<span font='Font Awesome 5 Free 14'></span>";
            "5" = "<span font='Font Awesome 5 Free 14'></span>";
            "6" = "<span font='Font Awesome 5 Free 14'></span>";
            "7" = "<span font='Font Awesome 5 Free 14'></span>";
            "8" = "<span font='Font Awesome 5 Free 14'></span>";
            "9" = "<span font='Font Awesome 5 Free 14'></span>";
            "10" = "<span font='Font Awesome 5 Free 14'></span>";
            urgent = " ";
            active = " ";
            default = " ";
          };
        };
        "hyprland/window" = {
          max-length = 30; # Limit window title length
        };
        network = {
          format = "{ifname}";
          format-wifi = "{signalStrength}% ";
          format-ethernet = "󰊗";
          format-disconnected = "";
          max-length = 20;
        };
        "hyprland/language" = {
          format = "{}";
          format-en = "EN";
          format-ru = "RU";
        };
        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-full = "{icon} Full";
          format-charging = " {icon} {capacity}%";
          format-plugged = " {capacity}%";
          format-icons = ["" "" "" "" ""];
        };
        clock = {
          format = "{:%H:%M}"; # Shorter time format
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          format-alt = "{:%m-%d}";
          tooltrip = true;
        };
        temperature = {
          critical-threshold = 85;
          format-critical = "{temperatureC}°C ";
          format = "{temperatureC}°C ";
        };
        pulseaudio = {
          format = "{icon}{volume}%";
          format-muted = "";
          format-icons = {
            default = ["󱡫"];
          };
          scroll-step = 2;
          on-click = "pavucontrol";
          tooltip = false; # Disable tooltip for compact view
        };
        backlight = {
          format = "{icon}{percent}%";
          format-icons = ["" ""];
        };
      };
    };
  };
}
