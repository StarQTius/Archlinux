#!/bin/fish

argparse -- $argv

set ui_dir $HOME/bin/ui

mkfifo audio_watcher.pipe

$ui_dir/control/audio.fish refresh &

while true
  read command volume_percentage volume_state < audio_watcher.pipe
  switch $command
    case update
    case '*'
      echo "Invalid command '$command'" >&2
  end

  printf "sound Sound %.3i%% %s⎸\n" \
    $volume_percentage \
    (progress --value=(if test $volume_state = on; echo $volume_percentage; else; echo 0; end) --max=200 --unit=4) \
  > status_bar.pipe
end
