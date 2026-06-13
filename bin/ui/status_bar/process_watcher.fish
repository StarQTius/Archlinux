#!/bin/fish

while true
  ps -ae -o pcpu,time,ucmd \
  | sort --reverse \
  | tail --lines=+2 \
  | sed -E --quiet "s/^([0-9]+\.[0-9]+) ([0-9]+:[0-9]+:[0-9]+) (.+)\$/\1 \2 \3/p" \
  | head --lines=1 \
  | read cpu_usage duration process_name

  echo "$duration" \
  | sed --regexp-extended 's/([0-9]+):([0-9]+):([0-9]+)/\1 \2 \3/' \
  | read duration_hours duration_minutes duration_seconds

  set pretty_duration (printf "%s%s%s" \
    "$(test "$duration_hours" -ne 0 && echo $duration_hours"h")" \
    "$(test "$duration_minutes" -ne 0 && echo $duration_minutes"min")" \
    "$(echo $duration_seconds"s")"
  )

  if test -n "$cpu_usage" -a -n "$process_name" -a "$cpu_usage" -ge 30
    echo "process ⎸$process_name@$cpu_usage% ($pretty_duration) ⎸" > status_bar.pipe
    sleep 1
  else
    echo "process" > status_bar.pipe
    sleep 1
  end
end
