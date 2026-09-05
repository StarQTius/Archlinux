for file in ~/bin/config.fish/*.fish
	source $file
end

for file in ~/bin/config.fish/*.sh
	bass source $file
end

if status is-interactive
	starship init fish | source
end
