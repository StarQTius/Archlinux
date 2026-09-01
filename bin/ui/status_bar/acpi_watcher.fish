#!/bin/fish

set original_brightness (brightnessctl get)

function main
  while read event
    if ! string match "*LID*" "$event" >/dev/null
      continue
    end

    set state (string replace --regex "^button/lid LID (.*)\$" "\1" "$event")
    switch "$state"
      case "open"
        echo "Fading in..." >&2
        fadein
      case "close"
        echo "Fading out..." >&2
        fadeout
      case "*"
        echo "Unrecognized event '$event' with state '$state'" >&2
    end
  end
end

function fadein
  set delta 250
  while test (brightnessctl get) -lt "$original_brightness"
    brightnessctl set "+$delta" >/dev/null
    sleep 0.01
  end
end

function fadeout
  set original_brightness (brightnessctl get)
  while test (brightnessctl get) -gt 0
    brightnessctl set 5%- >/dev/null
    sleep 0.01
  end
end

acpi_listen | main
