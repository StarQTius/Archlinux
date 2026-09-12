#!/bin/fish

argparse -- $argv

set this_script (status -f | xargs basename)
if test -n "$(pgrep --exact $this_script --ignore-ancestors)"
  exit 1
end

set user_choice (
  history \
  | nl \
  | string match --regex "^\s*[0-9]+\s*[^ ]+" \
  | sort --key=2 --key=1n \
  | uniq --skip-fields=1 \
  | sort --key=1n \
  | string replace --regex "^\s*[0-9]+\s*([^ ]+)\$" "\$1" \
  | fzf --reverse --color="bg:#000000" --print-query \
  | tail --lines=1
)

if test -z "$user_choice"
  exit 1
end

if which "$user_choice"
  history append "$user_choice"
  swaymsg exec -- "$user_choice"
else
  notify-send --urgency normal "'$user_choice': command not found"
end
