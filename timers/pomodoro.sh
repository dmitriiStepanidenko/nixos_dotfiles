#!/usr/bin/env bash

declare -a MESSAGES=( 
                     "30 minute lazy" \
                     "5 minut before end"
                     "30 minute work session Started" \
                     "5 minut before end"
                     "30 minute lazy" \
                     "5 minut before end"
                     "30 minute work session Started" \
                     "5 minut before end"
                     "30 minute lazy" \
                     "5 minut before end"
                     )
declare -a DELAYS=(1500 300 1500 300 1500 300 1500 300 1500 300)

for ((i=0; i<${#MESSAGES[@]}; i++)); do
  notify-send -e "${MESSAGES[$i]}" 
  sleep ${DELAYS[$i]}  
done
