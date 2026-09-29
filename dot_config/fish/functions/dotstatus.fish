function dotstatus --description 'Show what is out of sync between ~, the chezmoi source dir, and origin'
    set -l source (chezmoi source-path)
    set -l branch (git -C $source rev-parse --abbrev-ref HEAD)

    echo '── $HOME vs. source dir ─────────────────────────────'
    set -l status_out (chezmoi status)
    if test (count $status_out) -eq 0
        echo '  in sync'
    else
        printf '%s\n' $status_out
        echo
        echo '  first column  = the file in ~ changed since the last apply'
        echo '                  -> `dotpush` copies it into the source dir'
        echo '  second column = the source dir would change the file in ~'
        echo '                  -> `chezmoi apply` writes it out to ~'
    end

    echo
    echo '── source dir vs. its last commit ───────────────────'
    set -l dirty (git -C $source status --porcelain)
    if test (count $dirty) -eq 0
        echo '  clean'
    else
        printf '%s\n' $dirty
    end

    echo
    echo "── source dir ($branch) vs. origin ───────────────────"
    if not git -C $source fetch --quiet origin 2>/dev/null
        echo '  could not reach origin'
        return
    end
    set -l counts (git -C $source rev-list --left-right --count "origin/$branch...HEAD" 2>/dev/null | string split \t)
    if test (count $counts) -lt 2
        echo "  origin/$branch does not exist yet"
    else
        echo "  $counts[1] commit(s) to pull, $counts[2] commit(s) to push"
    end
end
