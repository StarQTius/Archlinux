#!/bin/fish

argparse -- $argv

set this_script (status -f | xargs basename)
if test -n "$(pgrep --exact $this_script --ignore-ancestors)"
  exit 1
end

echo $PATH \
  | xargs --delimiter=" " --replace=% fish -c'if test -d %; echo %; end' \
  | xargs --replace=% find % -type f -executable \
  | xargs --max-lines=1 basename \
  | sort \
	  | fzf --reverse --color=bg:black \
  | xargs --no-run-if-empty swaymsg exec --

