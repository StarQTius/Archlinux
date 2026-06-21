#!/bin/fish

function get_acpi_info
  argparse -- $argv

  set acpi_output_regex "Battery ([0-9]+): ([a-zA-Z ]+), ([0-9]+)%(, )?([0-9:]+)?.*"

  acpi |
  sed 's/charging at zero rate - will never fully charge\./00:00:00/' |
  grep --extended-regex --only-matching "$acpi_output_regex" |
  head --lines=1 |
  sed --regexp-extended "s/^$acpi_output_regex\$/\1 '\2' \3 \5/"
end

argparse -- $argv

set flasher 0
set critical_battery_charge 10
set refresh_period 1
set measures_max_count 10

while true
  get_acpi_info | read --tokenize battery_id battery_state battery_charge estimated_time

  if test "$previous_battery_state" != "$battery_state"
    set estimated_times
  end
  set previous_battery_state $battery_state

  if test -z "$estimated_time"
    set estimated_time "00:00:00"
  end

  set estimated_times (
    echo $estimated_time $estimated_times |
    cut --delimiter=" " --field=1-$measures_max_count)
  set measures_count (echo $estimated_times | wc --words)
  set median_index (math "ceil $measures_count / 2")

  echo $estimated_times |
  sed 's/ /\n/g' |
  sort |
  cut --delimiter=" " --field=$median_index |
  sed --regexp-extended 's/([0-9]+):([0-9]+):[0-9]+/\1 \2/g' |
  read estimate_hours estimate_minutes

  if test $flasher -eq 1 -a $battery_charge -lt $critical_battery_charge
    printf "battery Battery %.3i%%            %s⎸\n" \
      $battery_charge \
      (progress --value=$battery_charge --max=100 --unit=4) \
    > status_bar.pipe
  else
    printf "battery Battery %.3i%% (%sh%smin) <span foreground='#%02x%02x33'>%s</span>⎸\n" \
      "$battery_charge" \
      "$estimate_hours" \
      "$estimate_minutes" \
      (math \(100 - "$battery_charge"\) / 100 x 255) \
      (math "$battery_charge" / 100 x 255) \
      (progress --value=$battery_charge --max=100 --unit=4) \
    > status_bar.pipe
  end

  test $flasher -eq 1
  set flasher $status

  sleep $refresh_period
end
