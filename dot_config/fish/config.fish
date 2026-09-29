# fish is the interactive shell.
#
# Shortcuts shared with bash live in .chezmoidata/shortcuts.yaml and are
# rendered into conf.d/shortcuts.fish. Functions live in functions/.

# path
fish_add_path --path $HOME/.local/bin
fish_add_path --path $HOME/go/bin
fish_add_path --path $HOME/.cargo/bin
fish_add_path --path $HOME/.opencode/bin

set -gx VOLTA_HOME "$HOME/.volta"
if test -d "$VOLTA_HOME"
    fish_add_path --path $VOLTA_HOME/bin
end

# environment
set -gx EDITOR hx
set -gx COPILOT_CUSTOM_INSTRUCTIONS_DIRS $HOME

if test -r ~/.config/canonical/source-store-creds.txt
    set -gx CRAFT_SOURCE_STORE_AUTH_TOKEN (string trim < ~/.config/canonical/source-store-creds.txt)
end

# Machine-local overrides, not managed by chezmoi.
if test -f ~/.config/fish/vars.fish
    source ~/.config/fish/vars.fish
end

status is-interactive; or return

fish_vi_key_bindings
set -g fish_greeting

# fish-only shortcuts; the shared ones are in conf.d/shortcuts.fish.
abbr --add ctmp 'cd (mktemp -d)'
abbr --add c cd
abbr --add cl clear
abbr --add g git
abbr --add v hx

# `..`, `...`, `....` walk up that many directories.
abbr --add dotdot --regex '^\.\.+$' --function multicd

# These are defined as functions rather than abbreviations because they run a
# multi-step workflow; see ~/.local/share/chezmoi/README.md.
abbr --add dots dotstatus
abbr --add dotd dotdiff

# The install script only provides these on personal and canonical systems.
if command -q direnv
    direnv hook fish | source
end

if command -q starship
    starship init fish | source
end
