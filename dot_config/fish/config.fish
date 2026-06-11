fish_vi_key_bindings

abbr --add cdsc cd ~/dev/craft/snapcraft/snapcraft-main
abbr --add cdsca cd ~/dev/craft/snapcraft/snapcraft-a
abbr --add cdscb cd ~/dev/craft/snapcraft/snapcraft-b
abbr --add cdsce cd ~/dev/snaps/snapcraft-examples

abbr --add cdcc cd ~/dev/craft/charmcraft
abbr --add cdcce cd ~/dev/craft/charmcraft-examples

abbr --add cdsoc cd ~/dev/craft/sourcecraft
abbr --add cdsoce cd ~/dev/sources/sourcecraft-examples

abbr --add cdkc cd ~/dev/craft/kerncraft
abbr --add cdkce cd ~/dev/craft/kerncraft-examples

abbr --add cdic cd ~/dev/craft/imagecraft
abbr --add cdice cd ~/dev/craft/imagecraft-examples

abbr --add cdrc cd ~/dev/craft/rockcraft
abbr --add cdrce cd ~/dev/rocks/rockcraft-examples

abbr --add cdcpa cd ~/dev/craft/craft-parts
abbr --add cdcpae cd ~/dev/craft/craft-parts-examples

abbr --add cdcap cd ~/dev/craft/craft-application
abbr --add cdcli cd ~/dev/craft/craft-cli
abbr --add cdcg cd ~/dev/craft/craft-grammar
abbr --add cdcar cd ~/dev/craft/craft-archives
abbr --add cdcpl cd ~/dev/craft/craft-platforms
abbr --add cdcpr cd ~/dev/craft/craft-providers
abbr --add cdcst cd ~/dev/craft/craft-store
abbr --add cdsb cd ~/dev/craft/starbase
abbr --add cdsf cd ~/dev/craft/starflow
abbr --add cdss cd ~/dev/craft/starshow

abbr --add lxcsc lxc --project snapcraft
abbr --add lxccc lxc --project charmcraft
abbr --add lxcrc lxc --project rockcraft
abbr --add lxcsoc lxc --project sourcecraft

abbr --add ctmp 'cd (mktemp -d)'

abbr --add rg rg --smart-case --sort=path
abbr --add rgp rg --smart-case --sort=path --type=py

abbr --add l ls -1hF
abbr --add la ls -a1hF

abbr --add pyts "pytest --no-cov -vv --maxfail=1 --failed-first"
abbr --add pytsv "pytest --no-cov -vv --maxfail=1 --failed-first -s -o log_cli=true --log-cli-level=DEBUG"

abbr --add ga git add
abbr --add gbr git branch
abbr --add gch git checkout
abbr --add gcp "git add -A && git commit --no-verify -m 'checkpoint' && git status"
abbr --add gcs git commit --signoff -m
abbr --add gcrs git commit --reset-author --amend --signoff
abbr --add gd git diff
abbr --add gdh git diff HEAD~
abbr --add gf git fetch
abbr --add gfps "git fetch && git pull; git status"
abbr --add glo git log --oneline
abbr --add gmt git mergetool
abbr --add grb git rebase
abbr --add grbom git rebase --onto origin/main
abbr --add grh git reset --hard
abbr --add grhom git reset --hard origin/main
abbr --add gs git status
abbr --add gsw git switch
abbr --add gwt git worktree
abbr --add gsquash "git reset --soft HEAD~1 && git commit --all --amend --no-edit --no-verify"
abbr --add gfixup 'git add -A && git commit --no-verify -m "checkpoint" && git reset --soft HEAD~1 && git commit --all --amend --no-edit --no-verify'

if test -f ~/.config/fish/vars.fish
    source ~/.config/fish/vars.fish
end

abbr --add dotdot --regex '^\.\.+$' --function multicd

fish_add_path $HOME/go/bin
fish_add_path $HOME/.opencode/bin
fish_add_path $HOME/.local/bin

set -g fish_greeting

set -x COPILOT_CUSTOM_INSTRUCTIONS_DIRS $HOME

set -x EDITOR hx

direnv hook fish | source

starship init fish | source
