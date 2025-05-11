if status is-interactive
    # Commands to run in interactive sessions can go here
end


starship init fish | source

function y
	set tmp (mktemp -t "yazi-cwd.XXXXXX")
	yazi $argv --cwd-file="$tmp"
	if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
		builtin cd -- "$cwd"
	end
	rm -f -- "$tmp"
end


# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
test -r '/home/vachicorne/.opam/opam-init/init.fish' && source '/home/vachicorne/.opam/opam-init/init.fish' > /dev/null 2> /dev/null; or true
# END opam configuration
fish_add_path $HOME/go/bin

# Created by `pipx` on 2025-05-06 21:08:31
set PATH $PATH /home/vachicorne/.local/bin
zoxide init fish | source
