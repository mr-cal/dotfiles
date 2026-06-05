# dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

Includes configuration for fish, git, helix, kitty, and starship.

## Provisioning a new machine

### Generate a GPG key


```bash
gpg --full-generate-key
```

or without a tty:
```bash
gpg --full-generate-key --pinentry-mode loopback
```

### Install and pre-apply chezmoi

This installs chezmoi and makes the config template.


```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin init --apply mr-cal
```

### Complete template


Get your GPG key id:
```bash
gpg --list-secret-keys --with-colons --keyid-format LONG   | awk -F: '$1 == "sec" { print $5 }'
```

Complete the config template in `~/.config/chezmoi/chezmoi.toml`:
```bash
vim ~/.config/chezmoi/chezmoi.toml
```

### Apply chezmoi

This will install packages, configure git, and set up shell environments
based on the system type.

```bash
chezmoi apply
```
