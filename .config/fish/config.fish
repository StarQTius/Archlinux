for file in ~/bin/config.fish/*
	source $file
end

if status is-interactive
	starship init fish | source
end
