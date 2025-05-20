{
  lib,
  configLib,
  pkgs,
  ...
}: let
in {
  fonts.enableDefaultPackages = true;
  fonts.packages = with pkgs; [
    fira-code
    fira-code-symbols

    #droid-sans-mono
    noto-fonts-emoji
    mplus-outline-fonts.githubRelease

    symbola
    icon-library
  ];

  environment.systemPackages = with pkgs; [
    papirus-icon-theme
  ];

  programs.tmux = {
    terminal = "screen-256color";
    enable = true;
    keyMode = "vi";
    clock24 = true;
    escapeTime = 0;
    extraConfigBeforePlugins = ''
      set -g status-left-length 80

      # Tokyo night
      set -g @tokyo-night-tmux_theme storm    # storm | day | default to 'night'
      set -g @tokyo-night-tmux_transparent 1  # 1 or 0

      #set -g @tokyo-night-tmux_window_id_style digital
      #set -g @tokyo-night-tmux_pane_id_style hsquare
      #set -g @tokyo-night-tmux_zoom_id_style dsquare

      ## Icon styles
      #set -g @tokyo-night-tmux_terminal_icon 
      #set -g @tokyo-night-tmux_active_terminal_icon 

      ## No extra spaces between icons
      #set -g @tokyo-night-tmux_window_tidy_icons 0

      #set -g @tokyo-night-tmux_show_datetime 0
      #set -g @tokyo-night-tmux_date_format DMY
      #set -g @tokyo-night-tmux_time_format 24H

      #set -g @tokyo-night-tmux_show_path 1
      #set -g @tokyo-night-tmux_path_format relative # 'relative' or 'full'

      #set -g @tokyo-night-tmux_show_netspeed 1
      #set -g @tokyo-night-tmux_netspeed_iface "wlp1s0" # Detected via default route
      #set -g @tokyo-night-tmux_netspeed_showip 1      # Display IPv4 address (default 0)
      #set -g @tokyo-night-tmux_netspeed_refresh 1     # Update interval in seconds (default 1)

      #set -g @tokyo-night-tmux_show_battery_widget 1
      #set -g @tokyo-night-tmux_battery_name "BAT1"  # some linux distro have 'BAT0'
      #set -g @tokyo-night-tmux_battery_low_threshold 21 # default

      # powerline

      set -g TMUX_POWERLINE_SEG_WEATHER_LAT_DEFAULT "55.6"
      set -g TMUX_POWERLINE_SEG_WEATHER_LON_DEFAULT "37.5"
      set -g TMUX_POWERLINE_STATUS_JUSTIFICATION "left"

    '';
    extraConfig = ''
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      bind -r C-h select-window -t :-
      bind -r C-l select-window -t :+

      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # Pressing Ctrl-a locally will press Ctrl-b on remote host tmux
      bind -n C-a send-prefix

      setw -g mouse on

      # For yazi
      set -g allow-passthrough on
      set -ga update-environment TERM
      set -ga update-environment TERM_PROGRAM

      set-option -g focus-events on
      set-option -a terminal-features 'alacritty:RGB'

      set -g visual-activity off
    '';
    plugins = with pkgs; [
      tmuxPlugins.tokyo-night-tmux
      tmuxPlugins.tmux-powerline
    ];
  };
}
