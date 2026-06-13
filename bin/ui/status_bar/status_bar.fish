#!/bin/fish

argparse -- $argv

set this_script_dir (status --current-filename | xargs dirname)
set ui_dir $HOME/ui/control

mkfifo status_bar.pipe
$this_script_dir/audio_watcher.fish &
$this_script_dir/battery_watcher.fish &
$this_script_dir/clock_watcher.fish &
$this_script_dir/process_watcher.fish &

while true
  read command args < status_bar.pipe
  
  switch $command
    case battery
      set battery_status $args
    case sound
      set sound_status $args
    case brightness
      set brightness_status $args
    case clock
      set clock_status $args
    case process
      set process_status $args
    case '*'
      echo "Invalid command '$command'" >&2
      exit 1
  end
  
  printf "%s %s %s %s %s\n" \
    "$process_status" \
    "$battery_status" \
    "$sound_status" \
    "$brightness_status" \
    "$clock_status"
end
