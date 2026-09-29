function dotpush --description 'Copy edits from ~ into the source dir, then commit and push'
    argparse 'm/message=' -- $argv; or return 1

    set -l source (chezmoi source-path)
    set -l branch (git -C $source rev-parse --abbrev-ref HEAD)

    echo '==> Copying edits from ~ into the source dir...'
    chezmoi re-add -v; or return 1

    # `chezmoi re-add` deliberately skips templated files, so anything still
    # differing after it has run has to be edited in the source dir instead.
    set -l skipped (chezmoi status | string match -r '^.M')
    if test (count $skipped) -gt 0
        echo
        echo 'Note: these files in ~ still differ from the source dir but were'
        echo 'not copied back, because they are generated from templates.'
        echo 'Edit them with `chezmoi edit <file>` instead:'
        printf '%s\n' $skipped
    end

    set -l dirty (git -C $source status --porcelain)
    if test (count $dirty) -eq 0
        echo 'Nothing to commit.'
    else
        echo
        echo '==> Changes to commit:'
        git -C $source status --short
        echo
        git -C $source --no-pager diff --stat HEAD

        echo
        read --local --prompt-str 'Commit these? [y/N] ' reply
        if not string match -qir '^y' -- $reply
            echo 'Aborted. Nothing was committed.'
            return 1
        end

        git -C $source add -A; or return 1
        if set -q _flag_message
            git -C $source commit -m "$_flag_message"; or return 1
        else
            git -C $source commit; or return 1
        end
    end

    echo
    echo "==> Pushing to origin/$branch..."
    git -C $source push --set-upstream origin $branch
end
