#!/bin/fish

argparse -- $argv

echo $argv | read action value
switch $action
  case increase
    xbacklight -inc $value
  case decrease
    xbacklight -dec $value
  case refresh
  case '*'
    echo "Invalid action '$action'"
    exit 1
end

echo "update $(xbacklight -get)" > brightness_watcher.pipe
