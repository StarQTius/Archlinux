#!/bin/fish

while true
  ps -ae -o pcpu,etimes,ucmd \
  | tail --lines=+2 \
  | sort --reverse -n \
  | sed -E --quiet "s/^([0-9 ]+\.?[0-9]*)[ ]+([0-9]+) (.+)\$/\1 \2 \3/p" \
  | head --lines=1 \
  | read cpu_usage duration process_name

  top --batch --iterations=1 \
  | sed -E --quiet "/PID/{n;p}" \
  | read pid user pr ni virt res shr s cpu_usage mem duration command

  echo "$duration" \
  | sed -E "s/^([0-9]+):([0-9]+)\.[0-9]+\$/\1 \2/" \
  | read duration_minutes duration_seconds

  set duration_hours (math floor "$duration_minutes" / 60)
  set duration_minutes (math "$duration_minutes" % 60)

  set pretty_duration (printf "%s%s%ss" \
    "$(test "$duration_hours" -ne 0 && echo $duration_hours"h")" \
    "$(test "$duration_minutes" -ne 0 && echo $duration_minutes"min")" \
    "$duration_seconds"
  )

  set cpu_usage (math ceil "$cpu_usage")

  if test -n "$cpu_usage" -a -n "$process_name" -a "$cpu_usage" -ge 20
    printf "process ⎸%s@%.2f%% (%s) <span foreground='#%02x33%02x'>%s</span>⎸" \
      "$process_name" \
      "$cpu_usage" \
      "$pretty_duration" \
      (math floor "$cpu_usage" / 100 x 200) \
      (math 200) \
      (progress --value="$cpu_usage" --max=100 --unit=10) \
    > status_bar.pipe
    sleep 0.1
  else
    echo "process" > status_bar.pipe
    sleep 1
  end
end
