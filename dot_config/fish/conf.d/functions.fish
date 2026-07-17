function llm
    if test (count $argv) -ge 1
        set idx $argv[1]
    else
        set idx 1
    end
    set c "craft-llm-$idx"

    set target_cwd $HOME

    if string match -q "$HOME/dev*" "$PWD"
        if lxc exec "$c" -- test -d "$PWD" 2>/dev/null
            set target_cwd $PWD
        end
    end

    # Write the target CWD into the container as the user so they can remove it.
    # su -l (not lxc exec --user) runs PAM so all supplemental groups (lxd, etc) load.
    # Plain su -l with no -c/-s starts the user's login shell (fish) directly,
    # avoiding the TTY/setpgid issues that occur when wrapping with bash -c.
    # Remove any stale file (e.g. left from a root-owned previous run) before writing.
    lxc exec "$c" -- rm -f /tmp/llm-cwd
    echo $target_cwd | lxc exec --user (id -u) "$c" -- tee /tmp/llm-cwd > /dev/null
    lxc exec --force-interactive "$c" -- su -l (id -un)
end

function sb
    if test (count $argv) -ne 1
        echo "Usage: sb <brightness>"
        return 1
    end

    sudo ddcutil setvcp 10 $argv[1] --display 1; and sudo ddcutil setvcp 10 $argv[1] --display 2
end

function multicd
    echo cd (string repeat -n (math (string length -- $argv[1]) - 1) ../)
end
