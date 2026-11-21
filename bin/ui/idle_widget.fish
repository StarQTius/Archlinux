#!/bin/fish

switch (count $argv)
  case 4
    set transparent_color "$argv[1]"
    set selected_border_color "$argv[2]"
    set font_color "$argv[3]"
    set hint_border_color "$argv[4]"
  case '*'
    echo "Usage: $(status -f) TRANSPARENT_COLOR SELECTED_BORDER_COLOR FONT_COLOR HINT_BORDER_COLOR" >&2
    exit 1
end

swayidle timeout 10 \
  "swaymsg client.focused \
    '$transparent_color' \
    '$hint_border_color' \
    '$font_color' \
    '$hint_border_color'" \
  resume "swaymsg client.focused \
    '$transparent_color' \
    '$selected_border_color' \
    '$font_color' \
    '$selected_border_color'"
