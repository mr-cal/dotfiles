# dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

Includes configuration for fish, git, helix, kitty, and starship.

## Provisioning a new machine

1. Install chezmoi and apply the dotfiles:

```
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply mr-cal
```

2. Complete the config template in `~/.config/chezmoi/chezmoi.toml`.

```
vim ~/.config/chezmoi/chezmoi.toml
```

3. Generate a GPG key if you don't have one:

```
gpg --full-generate-key
gpg --list-secret-keys --keyid-format LONG
```

4. Re-apply to pick up the updated config:

```
chezmoi apply
```

This will install packages, configure git, and set up shell environments
based on the system type.
