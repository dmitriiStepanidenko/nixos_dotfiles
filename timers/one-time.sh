#!/usr/bin/env bash

send_message() {
  local message=$1
  notify-send -e "$message"  && play ./notification.wav
}

#notify-send -e "30 minutes"  && play ./notification.wav
send_message "45 minutes"
sleep $((40*60))
send_message "5 minutes remain"
sleep $((5*60))
send_message "Timer ended!"
#notify-send -e "After 5 minutes" && play ./notification.wav

