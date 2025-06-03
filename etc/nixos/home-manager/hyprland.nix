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
in {
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    settings = {
      #exec-once = ''${startupScript}/bin/start'';
      #general = {
      #lock_cmd = "pidof hyprlock || hyprlock"; # avoid starting multiple hyprlock instances.
      #before_sleep_cmd = "loginctl lock-session"; # lock before suspend.
      #after_sleep_cmd = "hyprctl dispatch dpms on"; # to avoid having to press a key twice to turn on the display.
      #};
      input = {
        kb_layout = "us,ru";
        kb_variant = "";
        options = "grp:win_space_toggle";
      };
      exec-once = [
        "sleep 2; ${pkgs.waybar}/bin/waybar 2>&1 > ~/waybar.log"
        #"${pkgs.swww}/bin/swww init 2>&1 > ~/swww_init.log &"
        "${pkgs.swww}/bin/swww img ${backgroundImage} 2>&1 > ~/swww.log"
      ];
      "$terminal" = "alacritty";
      "$mod" = "SUPER";
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
      bind =
        [
          "$mod, F, exec, firefox"
          "$mod, P, exec, ${pkgs.wofi}/bin/wofi --show run --xoffset=1670 --yoffset=12 --width=230px --height=984 --term=footclient --prompt=Run"
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

          "$mod SHIFT, S, exec, ${pkgs.hyprshot}/bin/hyprshot -m region"

          "CONTROL SHIFT, L, exec, ${pkgs.hyprlock}/bin/hyprlock"

          ",XF86MonBrightnessUp,exec,${pkgs.brightnessctl}/bin/brightnessctl set +5%"
          ",XF86MonBrightnessDown,exec,${pkgs.brightnessctl}/bin/brightnessctl set 5%-"
          ",XF86AudioRaiseVolume,exec, ${pkgs.pamixer}/bin/pamixer -i 5"
          ",XF86AudioLowerVolume,exec, ${pkgs.pamixer}/bin/pamixer -d 5"
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
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        grace = 300;
        hide_cursor = true;
        no_fade_in = false;
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
      #workspaces {
          margin: 0 5px;
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
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        spacing = 4;
        #output = [
        #      "eDP-1"
        #      "HDMI-A-1"
        #    ];
        modules-left = ["hyprland/workspaces" "wlr/taskbar" "hyprland/window"];
        modules-center = ["clock" "hyprland/language" "battery" "temperature"];
        modules-right = ["mpd" "pulseaudio" "backlight" "cpu" "memory"];

        "hyprland/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          warp-on-scroll = false;
          format = "{icon}";
          format-icons = {
            "1" = "1 <span font='Font Awesome 5 Free 14'></span>";
            "2" = "2 <span font='Font Awesome 5 Free 14'></span>";
            "3" = "3 <span font='Font Awesome 5 Free 14'></span>";
            "4" = "4 <span font='Font Awesome 5 Free 14'></span>";
            "5" = "5 <span font='Font Awesome 5 Free 14'></span>";
            "6" = "6 <span font='Font Awesome 5 Free 14'></span>";
            "7" = "7 <span font='Font Awesome 5 Free 14'></span>";
            "8" = "8 <span font='Font Awesome 5 Free 14'></span>";
            "9" = "9 <span font='Font Awesome 5 Free 14'></span>";
            "10" = "0 <span font='Font Awesome 5 Free 14'></span>";
            urgent = "";
            active = "";
            default = "";
          };
        };
        cpu = {
          "format" = "︁ {}%";
          tooltip = true;
        };
        memory = {
          format = "<span font='Font Awesome 5 Free 9'>︁</span> {used:0.1f}G/{total:0.1f}G";
          tooltip = true;
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
        };
        pulseaudio = {
          "format" = "<span font='Font Awesome 5 Free 11'>{icon:2}</span>{volume}%";
          "format-alt" = "<span font='Font Awesome 5 Free 11'>{icon:2}</span>{volume}%";
          "format-alt-click" = "click-right";
          "format-muted" = "<span font='Font Awesome 5 Free 11'></span>";
          "format-icons" = {
            "headphone" = "";
            "hands-free" = "";
            "headset" = "";
            "phone" = "";
            "portable" = "";
            "car" = "";
            "default" = ["" "" ""];
          };
          "scroll-step" = 2;
          "on-click" = "pavucontrol";
          "tooltip" = false;
        };
      };
    };
  };
  services.swww.enable = true;
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
