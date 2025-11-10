export XKB_DEFAULT_LAYOUT=gb
export TERM=alacritty
export SHELL=fish

pacman -Qeq > package_list
pipx list --json > pipx_list.json
npm list --global --depth=0 --json > npm_list.json
ls */Dockerfile */docker-compose.yml */CMakeUserPresets.json | xargs --replace=% fish --command "cp % dev-backup/(echo % | sed 's:/:.:')"

git add -A
git commit -m"Automatic backup"
git push

fish /home/paulin/bin/timekeeper &disown

dbus-update-activation-environment --all

if [ -z "$WAYLAND_DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ] ; then
    exec sway
fi
