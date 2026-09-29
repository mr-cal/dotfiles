function llm --description 'Open a shell in the craft-llm-N LXD container'
    set -l idx 1
    if test (count $argv) -ge 1
        set idx $argv[1]
    end
    set -l container "craft-llm-$idx"

    if not command -q lxc
        echo "llm: lxc is not installed" >&2
        return 1
    end

    if not lxc info "$container" >/dev/null 2>&1
        echo "llm: container '$container' does not exist" >&2
        return 1
    end

    # Enter the container at the current directory when it also exists there.
    set -l target_cwd $HOME
    if string match -q "$HOME/dev*" "$PWD"
        and lxc exec "$container" -- test -d "$PWD" 2>/dev/null
        set target_cwd $PWD
    end

    # Write the target cwd into the container as the user so they can remove it.
    # su -l (not lxc exec --user) runs PAM so all supplemental groups (lxd, etc)
    # load. Plain su -l with no -c/-s starts the user's login shell (fish)
    # directly, avoiding the TTY/setpgid issues that occur when wrapping with
    # bash -c. Remove any stale file (for example one left root-owned by a
    # previous run) before writing.
    lxc exec "$container" -- rm -f /tmp/llm-cwd
    echo $target_cwd | lxc exec --user (id -u) "$container" -- tee /tmp/llm-cwd >/dev/null
    lxc exec --force-interactive "$container" -- su -l (id -un)
end
