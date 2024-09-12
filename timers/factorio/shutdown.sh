#!/bin/bash
## Solution with screen
SCREEN_NAME="factorio"

# Function to send a message to the screen session
send_to_screen() {
        local message=$1
        screen -S $SCREEN_NAME -p 0 -X stuff "$message^M"
}

# Define the countdown and the delay between messages
declare -a MESSAGES=( "Дед, выпей таблетки" \
                     "Server will shut down in 10 minutes" \
                     "Server will shut down in 5 minutes" \
                     "Server will shut down in 1 minute" \
                     "Server is shutting down now")
declare -a DELAYS=(1800 300 240 60 1)
# 5 4 1

 Send pre-shutdown messages
for ((i=0; i<${#MESSAGES[@]}; i++)); do
        send_to_screen "${MESSAGES[$i]}"
        sleep ${DELAYS[$i]}
done

# Send save and quit commands
send_to_screen "Saving"
send_to_screen "/save"
sleep 5 # Adding a small delay to ensure the save completes
send_to_screen "Quitting"
send_to_screen "/quit"

# Allow some time for the server to shutdown gracefully
sleep 10

## Solution with PIDS
## Find the game server PID
#PID=$(pgrep factorio)
#if [ -z "$PID" ]; then
#    echo "Game server is not running."
#    exit 1
#fi
#
## Define the countdown and the delay between messages
#declare -a MESSAGES=("Server will shut down in 10 minutes" \
#                     "Server will shut down in 5 minutes" \
#                     "Server will shut down in 1 minute" \
#                     "Server is shutting down now")
#declare -a DELAYS=(300 240 240 60)
#
## Function to send messages to the server
#send_message() {
#    local message=$1
#    echo "$message\n" > /proc/$PID/fd/0
#}
#
## Send pre-shutdown messages
#for ((i=0; i<${#MESSAGES[@]}; i++)); do
#    send_message "${MESSAGES[$i]}"
#    sleep ${DELAYS[$i]}
#done
#
#send_message "/save"
#sleep 15
#send_message "/quit\n"
#sleep 10
#
## Shut down the server
#kill -SIGINT $PID
