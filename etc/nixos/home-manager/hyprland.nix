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
in {
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    settings = {
      #exec-once = ''${startupScript}/bin/start'';
      exec-once = [
        "${pkgs.waybar}/bin/waybar 2>&1 > ~/waybar.log"
        #"${pkgs.swww}/bin/swww init 2>&1 > ~/swww_init.log &"
        "${pkgs.swww}/bin/swww img ${../../../images/wanderer.jpg} 2>&1 > ~/swww.log"
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
  programs.hyprlock.enable = true;
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
