#!/bin/fish

argparse -- $argv
  
while true
  set date (date +'%a %e %B %Y - %I:%M %p')
  printf "clock %s" $date > status_bar.pipe
  
  set elapsed_seconds (date +'%S')
  set seconds_to_sleep (math "60 - $elapsed_seconds")
  sleep $seconds_to_sleep
end
