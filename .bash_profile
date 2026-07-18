export XKB_DEFAULT_LAYOUT=gb
export TERM=alacritty
export SHELL=fish
export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_DESKTOP=sway

if [ -z "$TOP_LEVEL_INIT" ]; then
  echo "Saving Pacman package list"
  pacman -Qeq > package_list
  
  echo "Saving pipx package list"
  pipx list --json > pipx_list.json

  echo "Saving npm package list"
  npm list --global --depth=0 --json > npm_list.json
  
  echo "Saving home project Dockerfiles"
  find */Dockerfile */docker-compose.yml */CMakeUserPresets.json */.git/hooks -type f \
  | xargs --replace=% fish --command "cp % dev-backup/(echo % | sed 's|/|.|g')"

  echo "Pushing save"
  git add -A
  git commit -m"Automatic backup"
  git push

  echo "Update dbus activation environment"
  dbus-update-activation-environment --all

  # echo "Start time keeping"
  # fish /home/paulin/bin/timekeeper &disown
  
  export TOP_LEVEL_INIT=1

  echo "Start sway"
  exec sway
fi
