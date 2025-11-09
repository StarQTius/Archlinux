#!/bin/bash

if [ -z "$GNOME_KEYRING_CONTROL" ]; then
  eval $(dbus-launch --sh-syntax)
  eval $(echo "" | gnome-keyring-daemon --unlock --components=secrets 2>/dev/null)
  export GNOME_KEYRING_CONTROL
fi
