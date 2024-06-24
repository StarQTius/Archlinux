#!/bin/fish

function volume
  argparse -- $argv

  echo $argv | read action value
  switch $action
    case increase
      amixer set Master $value%+
    case decrease
      amixer set Master $value%-
    case '*'
      echo "Invalid action '$action'" >&2
      exit 1
  end
end

argparse -- $argv

set amixer_output_regex "\w+: Playback ([0-9]+) \[([0-9]+)%\] \[(-?[0-9]+.[0-9]+)dB\] \[(on|off)\]"

echo $argv | read domain args
switch $domain
  case toggle_mute
    amixer set Master toggle
  case volume
    volume $args
  case previous
    playctl previous
  case next
    playctl next
  case toggle_play
    playclt play-pause
  case refresh
  case '*'
    echo "Invalid domain '$domain'" >&2
    exit 1
end

amixer get Master |
grep --extended-regexp --only-matching "$amixer_output_regex" |
head --lines=1 |
sed --regexp-extended "s/^$amixer_output_regex\$/\1 \2 \3 \4/" |
read volume volume_percentage volume_gain volume_state

echo "update $volume_percentage $volume_state" > audio_watcher.pipe
