# dotfiles

mr-cal's personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

---

## Provisioning a new machine

```bash
gpg --full-generate-key
gpg --list-secret-keys --with-colons --keyid-format LONG | awk -F: '$1 == "sec" { print $5 }'
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin init --apply mr-cal
```

Prompt responses are stored in `~/.config/chezmoi/chezmoi.toml`.

---

## Workflow

There are three copies of every dotfile. Files are managed with the following commands:

```
                                      ─────► dotpush ─────►
  ┌──────────────┐  chezmoi re-add  ┌────────────────────────┐   git push   ┌──────────┐
  │      ~       │ ───────────────► │ ~/.local/share/chezmoi │ ───────────► │  GitHub  │
  │ (live files) │                  │      (source dir)      │              │ (origin) │
  │              │ ◄─────────────── │                        │ ◄─────────── │          │
  └──────────────┘  chezmoi apply   └────────────────────────┘   git pull   └──────────┘
                                      ◄───── dotpull ◄─────
```

---

## Helper commands

I have a hard time recalling what a chezmoi command will do based on it's name and
I don't use it often enough to commit the behaviors to memory. The following fish
and bash aliases are easier to understand:

| Command | Description |
| --- | --- |
| `dotstatus` | Shows the status of all three copies of the dotfiles. |
| `cddot`   | Goes to `~/.local/share/chezmoi` |
| `dotdiff` | Shows what `chezmoi apply` would change when updating live files from the source dir. |
| `dotpush` | Copies live files into the source dir, shows the diff, then commits and pushes. |
| `dotpull` | `git pull` from origin in the source dir, shows what live files would be changes, then makes those changes with `chezmoi apply`. |

`dotpush` and `dotpull` always ask for comfirmation before making any changes.

---

## `chezmoi apply` prompt

`apply` applies files from the source to the live dirs. When there are live changes
that would be overwritten, it will prompt you with:

```
.bashrc has changed since chezmoi last wrote it (diff/overwrite/all-overwrite/skip/quit)?
```


| Action | Description |
| --- | --- |
| diff | Show the diff. |
| overwrite | Replace the live file with the source file. Local edits to that file will be lost. |
| all-overwrite | Overwrite all live files with the source files. |
| skip | Leave the live file alone. Nothing is lost but the file stays out of sync. |
| quit | Stop the apply. Files already written stay written. |

In the `diff` output:

- `-` lines are what is in the live file
- `+` lines are what is in the source dir

---

## Untangling a conflict

To resolve differences between your live, source, and upstream files:

### Check the status

```fish
dotstatus
chezmoi diff ~/.bashrc
```

### Resolve local conflicts

**Keep live file, discard source file.**

```fish
chezmoi re-add ~/.bashrc      # copy live file into the source dir
dotpush                       # commit and push it
```

**Keep source file, discard live file.**

```fish
chezmoi apply --force ~/.bashrc
```

**Merge manually.**

```fish
chezmoi merge ~/.bashrc
dotpush
```

This opens a three-way `vimdiff` between the live file, the source file, and the last
applied state. After saving the merged result, chezmoi writes it into the source
dir.

### Resolve remote conflicts

```fish
cddot
git status
git pull --rebase origin main
```

---

## Security

- `autoCommit` and `autoPush` are off, in favor of `dotpush`, which runs the gitleaks
  pre-commit hook.
- Secrets are ignored with `.chezmoiignore` and `.gitignore`.
- Machine-local vars are in the unmanaged `~/.config/fish/vars.fish` file.
- Git credentials are written to ~/.git-credentials for headless use, so be advised on
  shared machines.

---

## Misc

### Harper-ls dictionary

harper-ls appends learned words to `~/.config/harper-ls/dictionary.txt` at
runtime. Managing it as a normal file makes it conflict on every single apply. So
`create_dictionary.txt` seeds the dictionary once on a new machine and then leaves it
alone forever. Run `chezmoi add ~/.config/harper-ls/dictionary.txt` to manually capture
new words into the repo.

### Adding a shell alias

`.chezmoidata/shortcuts.yaml` defines shell aliases or shortcuts. Adding an alias here
will ensure it's defined for bash and fish.
