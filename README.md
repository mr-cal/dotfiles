# dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

Includes configuration for fish, git, helix, kitty, and starship.

## Provisioning a new machine

1. Generate a GPG key if you don't have one and note the key ID:

```
gpg --full-generate-key
gpg --list-secret-keys --keyid-format LONG
```

2. Install chezmoi and apply the dotfiles:

```
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin init --apply mr-cal
```

3. Complete the config template in `~/.config/chezmoi/chezmoi.toml` with your
   email, GPG signing key, and system type (`personal`, `canonical`, or `server`):

```
vim ~/.config/chezmoi/chezmoi.toml
```

4. Re-apply to pick up the updated config:

```
chezmoi apply
```

This will install packages, configure git, and set up shell environments
based on the system type.
