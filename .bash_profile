export XKB_DEFAULT_LAYOUT=gb
export TERM=alacritty
export SHELL=fish

pacman -Qeq > package_list
ls */Dockerfile */docker-compose.yml | xargs --replace=% fish --command "cp % dev-backup/(echo % | sed 's:/:.:')"

git add -A
git commit -m"Automatic backup"
git push

sway
