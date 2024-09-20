#!/bin/fish

argparse -- $argv

set this_script (status -f | xargs basename)
if test -n "$(pgrep --exact $this_script --ignore-ancestors)"
  exit 1
end

echo $PATH \
  | xargs --delimiter=" " --replace=% fish -c'if test -d %; echo %; end' \
  | xargs --replace=% find % -type f -executable -follow \
  | xargs --max-lines=1 basename \
  | fzf --reverse --color=bg:#000000 \
  | xargs --no-run-if-empty which \
  | xargs --no-run-if-empty swaymsg exec --

