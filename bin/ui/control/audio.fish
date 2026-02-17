#!/bin/fish

function volume
  argparse -- $argv

  echo $argv | read action value
  switch $action
    case increase
      wpctl set-volume @DEFAULT_AUDIO_SINK@ $value%+
    case decrease
      wpctl set-volume @DEFAULT_AUDIO_SINK@ $value%-
    case '*'
      echo "Invalid action '$action'" >&2
      exit 1
  end
end

argparse -- $argv

set amixer_output_regex "Volume: ([0-9]+.[0-9]+)\s?(\[MUTED\])?"

echo $argv | read domain args
switch $domain
  case toggle_mute
    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
  case volume
    volume $args
  case previous
    playerctl previous
  case next
    playerctl next
  case toggle_play
    playerctl play-pause
  case refresh
  case '*'
    echo "Invalid domain '$domain'" >&2
    exit 1
end

wpctl get-volume @DEFAULT_AUDIO_SINK@ |
sed --regexp-extended "s/^$amixer_output_regex\$/\1 \2/" |
read volume_percentage volume_state

printf "update %s %s"\
  (math $volume_percentage x 100) \
  (if test "$volume_state" = "[MUTED]"; echo "off"; else; echo "on"; end) \
> audio_watcher.pipe
