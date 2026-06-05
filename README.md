# dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

Includes configuration for fish, git, helix, kitty, and starship.

## Provisioning a new machine

1. Generate a GPG key if you don't have one and note the key ID:

```bash
gpg --full-generate-key
```

or without a tty:
```bash
gpg --full-generate-key --pinentry-mode loopback
```

2. Install chezmoi and apply the dotfiles:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin init --apply mr-cal
```

3. Complete the config template in `~/.config/chezmoi/chezmoi.toml` with your
   email, GPG signing key, and system type (`personal`, `canonical`, or `server`):

```bash
gpg --list-secret-keys --with-colons --keyid-format LONG   | awk -F: '$1 == "sec" { print $5 }'
```

```bash
vim ~/.config/chezmoi/chezmoi.toml
```

4. Re-apply to pick up the updated config:

```bash
chezmoi apply
```

This will install packages, configure git, and set up shell environments
based on the system type.
