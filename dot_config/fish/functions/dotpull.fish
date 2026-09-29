function dotpull --description 'Pull dotfiles from origin and apply them to ~'
    set -l source (chezmoi source-path)
    set -l branch (git -C $source rev-parse --abbrev-ref HEAD)

    set -l dirty (git -C $source status --porcelain)
    if test (count $dirty) -gt 0
        echo 'dotpull: the source dir has uncommitted changes:' >&2
        git -C $source status --short >&2
        echo >&2
        echo 'Run dotpush first, or set them aside with:' >&2
        echo "    git -C $source stash" >&2
        return 1
    end

    echo "==> Pulling origin/$branch..."
    git -C $source pull --rebase origin $branch; or return 1

    echo
    echo '==> These files in ~ would change:'
    chezmoi diff

    echo
    read --local --prompt-str 'Apply to ~? [y/N] ' reply
    if not string match -qir '^y' -- $reply
        echo 'Aborted. Nothing in ~ was changed.'
        return 1
    end

    chezmoi apply -v
end
