export XKB_DEFAULT_LAYOUT=gb
export TERM=alacritty
export SHELL=fish

if [ -z "$TOP_LEVEL_INIT" ]; then
  pacman -Qeq > package_list
  pipx list --json > pipx_list.json
  npm list --global --depth=0 --json > npm_list.json
  ls */Dockerfile */docker-compose.yml */CMakeUserPresets.json | xargs --replace=% fish --command "cp % dev-backup/(echo % | sed 's:/:.:')"

  git add -A
  git commit -m"Automatic backup"
  git push

  dbus-update-activation-environment --all
  fish /home/paulin/bin/timekeeper &disown
  
  export TOP_LEVEL_INIT=1

  exec sway
fi
