#!/bin/fish

argparse -- $argv

set ui_dir $HOME/bin/ui

mkfifo brightness_watcher.pipe

$ui_dir/control/brightness.fish refresh &

while true
  read command brightness < brightness_watcher.pipe
  switch $command
    case update
    case '*'
      echo "Invalid command '$command'" >&2
  end

  printf "brightness Brightness %.3i%% %s⎸\n" \
    $brightness \
    (progress --value=$brightness --max=100 --unit=4) \
  > status_bar.pipe
end
