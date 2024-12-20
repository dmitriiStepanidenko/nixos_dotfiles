#!/usr/bin/env bash

# Toggle dark and light themes for firefox, tmux, alacritty,
# and (neo)vim. Either run it from a shell or add a keybinding
# in tmux / alacritty

BASEFOLDER="/home/dmitrii/dotfiles/"

LIGHTTHEME="catppuccin-latte"
DARKTHEME="catppuccin-mocha"

VIMCONF="${BASEFOLDER}/config/nvim/lua/config/set.lua"
ALACRITTYCONF="${XDG_CONFIG_HOME}/alacritty/alacritty.yml"
TMUXCONF="${XDG_CONFIG_HOME}/tmux/tmux.conf"
CURRENT_MODE=$(gsettings get org.gnome.desktop.interface color-scheme)



# Function to switch theme in n(v)im panes inside tmux

switch_vim_theme() {

  theme_for_vim_panes="$1"

  tmux list-panes -a -F '#{pane_id} #{pane_current_command}' |

    grep vim | # this captures vim and nvim

    cut -d ' ' -f 1 |

    xargs -I PANE tmux send-keys -t PANE ESCAPE \

      ":set background=${theme_for_vim_panes}" ENTER

}



# Toggle logic based on current mode

if [ "$CURRENT_MODE" = "'prefer-dark'" ]; then

  gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'

  sed -i "s/${DARKTHEME}/${LIGHTTHEME}/" "$ALACRITTYCONF" "$TMUXCONF"

  sed -i 's/dark/light/' "$VIMCONF"

  switch_vim_theme "light"

else

  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

  sed -i "s/${LIGHTTHEME}/${DARKTHEME}/" "$ALACRITTYCONF" "$TMUXCONF"

  sed -i 's/light/dark/' "$VIMCONF"

  switch_vim_theme "dark"

fi



tmux source-file "$TMUXCONF"

