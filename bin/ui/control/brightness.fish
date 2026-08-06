#!/bin/fish

argparse -- $argv

echo $argv | read action value
switch $action
  case increase
    brightnessctl set +$value%
  case decrease
    brightnessctl set $value%-
  case refresh
  case '*'
    echo "Invalid action '$action'"
    exit 1
end

echo "update $(math 100 x (brightnessctl get) / (brightnessctl max))" > brightness_watcher.pipe
