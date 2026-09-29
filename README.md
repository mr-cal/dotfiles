# dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

Configuration for bash, fish, git, helix, kitty, starship, vim, and harper-ls,
plus a script that installs packages on a new machine.

---

## The mental model (read this first)

There are **three** copies of every dotfile, and every confusing chezmoi
message is about a disagreement between two of them:

```
  ┌──────────────────┐   dotpush    ┌──────────────────┐   dotpush   ┌────────┐
  │        ~         │ ───────────► │   source dir     │ ──────────► │ origin │
  │  (the live file  │              │ ~/.local/share/  │             │ GitHub │
  │   you actually   │ ◄─────────── │     chezmoi      │ ◄────────── │        │
  │      use)        │ chezmoi apply│ (a git repo)     │  git pull   │        │
  └──────────────────┘              └──────────────────┘             └────────┘
                                          dotpull
```

Two rules explain almost everything:

1. **chezmoi never watches `~`.** If you edit `~/.bashrc` in your editor,
   nothing happens automatically. You must run `chezmoi re-add` (which
   `dotpush` does for you) to copy that edit into the source dir.
2. **`chezmoi apply` always goes source dir → `~`, and it always wins.**
   It overwrites whatever is in `~`. That is why it asks before clobbering
   a file you have edited.

The source dir is a normal git repo. You can `cd` into it (`cddot`) and use
git exactly as you would anywhere else.

---

## Everyday commands

Four wrappers cover ~95% of what you need. They exist as fish functions and as
bash functions, and are defined in `dot_config/fish/functions/` and
`dot_bashrc`.

| Command | What it does |
| --- | --- |
| `dotstatus` | Shows all three gaps at once: `~` vs. source, source vs. last commit, source vs. origin. **Start here whenever you are unsure.** |
| `dotdiff` | Shows exactly what `chezmoi apply` would change in `~`. Read-only. |
| `dotpush` | `chezmoi re-add` (slurp your `~` edits into the source dir) → show the changes → confirm → commit → push. |
| `dotpull` | `git pull` in the source dir → show what would change in `~` → confirm → `chezmoi apply`. |

Both `dotpush` and `dotpull` show you what is about to happen and ask for
confirmation before committing or writing anything.

`dotpush -m "message"` skips the editor and uses that commit message.

### The underlying chezmoi commands

If you'd rather type them directly:

| chezmoi command | Direction | Effect |
| --- | --- | --- |
| `chezmoi status` | — | Two-column summary (decoded below) |
| `chezmoi diff` | — | What `apply` would change in `~` |
| `chezmoi apply` | source → `~` | Write the source dir out to `~` |
| `chezmoi re-add` | `~` → source | Copy your `~` edits back into the source dir |
| `chezmoi add <file>` | `~` → source | Start managing a **new** file |
| `chezmoi forget <file>` | — | Stop managing a file (leaves `~` untouched) |
| `chezmoi edit <file>` | — | Edit the **source** version of a file |
| `chezmoi edit --apply <file>` | — | Edit the source version, then apply it |
| `chezmoi update` | origin → source → `~` | `git pull` **and** `apply`, no confirmation |
| `chezmoi cd` | — | Open a shell in the source dir |
| `chezmoi git -- <args>` | — | Run git in the source dir |

> `chezmoi update` is the unguarded version of `dotpull`. It applies without
> asking. Prefer `dotpull`.

---

## Reading `chezmoi status`

`chezmoi status` prints two columns, and they mean **different** things. This
is the single most confusing part of chezmoi.

```
MM .config/helix/languages.toml
│└─ second column: source dir vs. ~   → what `chezmoi apply` WILL DO to ~
└── first column:  ~ vs. last apply   → what YOU changed in ~ since last apply
```

| Output | Meaning | What to do |
| --- | --- | --- |
| `_M` | You have not touched `~`, but the source dir has newer content. | `dotpull` or `chezmoi apply` — safe. |
| `M_` | You edited the file in `~`; the source dir agrees with the result. | Usually already handled; `dotpush` to commit it. |
| `MM` | **Conflict.** You edited `~` *and* the source dir changed. | See "Untangling a conflict" below. |
| `_A` | `chezmoi apply` will create this file in `~`. | Fine, it's new. |
| `_D` | `chezmoi apply` will delete this file from `~` (listed in `.chezmoiremove`). | Fine, it's intentional. |
| `_R` | A `run_` script will be executed on the next apply. | Fine. |

(`_` above means a space.)

---

## Decoding the `diff/overwrite/all-overwrite/skip/quit` prompt

`chezmoi apply` prints this when it is about to write a file in `~` that you
have modified since the last apply:

```
.bashrc has changed since chezmoi last wrote it (diff/overwrite/all-overwrite/skip/quit)?
```

**The file being overwritten is always the one in `~`.** chezmoi is never
asking about the source dir, and never about origin. The source dir is a git
repo, so nothing you choose here can lose committed work — only your
uncommitted edit to that file in `~` is at risk.

| Answer | Key | What happens |
| --- | --- | --- |
| **diff** | `d` | Show the difference, then ask again. Always safe — start here. |
| **overwrite** | `o` | Replace the file in `~` with the source version. **Your local edit to that file is lost.** |
| **all-overwrite** | `a` | Overwrite this file and every remaining one without asking again. |
| **skip** | `s` | Leave the file in `~` alone. Nothing is lost; the file stays out of sync. |
| **quit** | `q` | Stop the apply. Files already written stay written. |

**When in doubt, press `d` and then `s`.** Nothing is destroyed, and you can
decide deliberately afterwards.

In the `diff` output:

- `-` lines are what is in `~` **right now** (your version)
- `+` lines are what the source dir **would write** (the repo's version)

So if the `-` lines are the ones you want to keep, answer `skip` and then run
`chezmoi re-add ~/.bashrc` to push your version into the source dir instead.

---

## Untangling a conflict

You have a local edit in `~` **and** a different change in the source dir
(usually one you pulled from another machine). Work through this in order.

### 1. See exactly what is going on

```fish
dotstatus                     # which of the three gaps are open?
chezmoi diff ~/.bashrc        # what would apply do to this file?
```

In `chezmoi diff`, `-` is the current content of `~` and `+` is what the
source dir would write.

### 2. Decide which side you want

**I want my `~` edit; discard the source version.**

```fish
chezmoi re-add ~/.bashrc      # copy ~ into the source dir
dotpush                       # commit and push it
```

**I want the source version; discard my `~` edit.**

```fish
chezmoi apply --force ~/.bashrc
```

`--force` skips the prompt and overwrites `~` unconditionally.

**I want to keep both — merge them by hand.**

```fish
chezmoi merge ~/.bashrc
```

This opens a three-way `vimdiff` between `~`, the source dir, and the last
applied state. Save the merged result and chezmoi writes it into the source
dir for you. Then `dotpush`.

To merge everything that conflicts in one pass:

```fish
chezmoi merge-all
```

### 3. If the source dir and origin have diverged

This is ordinary git, not chezmoi:

```fish
cddot
git status
git pull --rebase origin main   # replay your local commits on top of origin
```

If the rebase stops on a conflict, resolve the files, `git add` them, and run
`git rebase --continue`. To bail out entirely: `git rebase --abort`.

---

## "I've made a mess, get me back to a known state"

Pick the outcome you want.

**Throw away my uncommitted `~` edits, take whatever is committed.**

```fish
cddot
git status                      # confirm nothing valuable is uncommitted
chezmoi apply --force
```

**Throw away my uncommitted *source dir* changes.**

```fish
cddot
git restore .                   # undo modifications to tracked files
git clean -nd                   # DRY RUN: list untracked files
git clean -fd                   # actually delete them
```

**Reset the source dir to exactly match origin.**

```fish
cddot
git fetch origin
git reset --hard origin/main
chezmoi apply --force
```

> This discards every local commit that has not been pushed. Check
> `git log origin/main..HEAD` first to see what you would lose.

**Just tell me what would happen, change nothing.**

```fish
dotstatus
dotdiff
chezmoi apply --dry-run --verbose
```

Every destructive chezmoi command accepts `--dry-run` and `--verbose`. Use
them freely.

**Stop managing one file without deleting it.**

```fish
chezmoi forget ~/.config/foo/bar
```

The file stays in `~` untouched; chezmoi just stops caring about it. To also
delete it from `~` on every machine, add it to `.chezmoiremove` instead.

---

## Repository layout

```
.chezmoi.toml.tmpl          Generates ~/.config/chezmoi/chezmoi.toml; prompts on init
.chezmoidata/shortcuts.yaml Single source of truth for bash aliases + fish abbreviations
.chezmoiignore              Files in this repo that must NOT be written to ~
.chezmoiremove              Files chezmoi actively DELETES from ~
.chezmoiscripts/            Scripts run during apply, never written to ~
dot_bashrc                  → ~/.bashrc
dot_config/                 → ~/.config/
executable_dot_vimrc        → ~/.vimrc, with the executable bit set
```

### Naming attributes

chezmoi encodes file attributes in the source filename:

| Prefix | Meaning |
| --- | --- |
| `dot_` | Becomes a leading `.` in the target name |
| `executable_` | Sets the executable bit |
| `symlink_` | The file's contents are the symlink target |
| `create_` | Created only if absent; **never overwritten afterwards** |
| `run_onchange_` | A script, re-run whenever its rendered content changes |
| `.tmpl` suffix | Rendered as a Go template before being written |

Two of these solve specific problems here:

- **`create_dictionary.txt`** — harper-ls appends learned words to
  `~/.config/harper-ls/dictionary.txt` at runtime. Managing it as a normal
  file made it conflict on every single apply. As a `create_` file, chezmoi
  seeds it once on a new machine and then leaves it alone forever. Run
  `chezmoi add ~/.config/harper-ls/dictionary.txt` when you want to capture
  new words into the repo.
- **`.tmpl` files cannot be `re-add`ed.** `chezmoi re-add` refuses to
  overwrite a template, because it cannot un-render one. So editing
  `~/.config/git/config` directly is a dead end — the edit will sit there
  unsynced forever. Edit the template instead:

  ```fish
  chezmoi edit --apply ~/.config/git/config
  ```

  `dotpush` warns you when it finds a file in this situation.

### Templated files (edit in the source dir, not in `~`)

- `.chezmoi.toml.tmpl`
- `dot_config/git/config.tmpl`
- `dot_config/bash/shortcuts.sh.tmpl` *(generated from `.chezmoidata/shortcuts.yaml`)*
- `dot_config/fish/conf.d/shortcuts.fish.tmpl` *(same)*
- `.chezmoiscripts/run_onchange_install-packages.sh.tmpl`

Everything else is a plain file that you can edit in `~` and `dotpush`.

### Adding a shell shortcut

Do **not** edit `dot_bashrc` or `config.fish`. Add an entry to
`.chezmoidata/shortcuts.yaml` and run `chezmoi apply`; both shells pick it up.
This is why the two shells can no longer drift apart.

---

## Provisioning a new machine

### 1. Create a GPG key for signing commits

```bash
gpg --full-generate-key
```

Without a TTY:

```bash
gpg --full-generate-key --pinentry-mode loopback
```

Get the key ID:

```bash
gpg --list-secret-keys --with-colons --keyid-format LONG | awk -F: '$1 == "sec" { print $5 }'
```

### 2. Install and apply

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin init --apply mr-cal
```

chezmoi prompts for three things and writes them to
`~/.config/chezmoi/chezmoi.toml`:

| Prompt | Value |
| --- | --- |
| System type | `personal`, `canonical`, or `server` |
| Git email address | The email for commits |
| GPG signing key ID | From step 1 |

`system_type` controls what gets installed and configured:

| | `personal` | `canonical` | `server` |
| --- | --- | --- | --- |
| Core apt packages, fish, helix | ✅ | ✅ | ✅ |
| Desktop apt packages, gh, direnv | ✅ | ✅ | ❌ |
| fish as the default shell | ✅ | ✅ | ❌ |
| Language servers, rust, go, uv, lxd | ✅ | ✅ | ❌ |
| starship, kitty, harper-ls | ✅ | ✅ | ❌ |
| kitty config in `~/.config` | ✅ | ✅ | ❌ |
| google-cloud-sdk, pycharm | ❌ | ✅ | ❌ |
| VirtualBox | ✅ | ❌ | ❌ |

The apply runs `.chezmoiscripts/run_onchange_install-packages.sh`, which needs
`sudo`. It is re-run automatically whenever its contents change.

### 3. Re-running the prompts

To change an answer later:

```fish
chezmoi init          # re-prompts for anything missing
```

The prompts use `...Once` variants, so existing answers in
`~/.config/chezmoi/chezmoi.toml` are reused and not asked again. To change one,
edit that file directly — it is deliberately **not** managed by chezmoi, so it
can hold machine-specific values.

---

## Conventions and gotchas

- **`autoCommit` and `autoPush` are deliberately off.** chezmoi's built-in
  auto-commit writes to git through an internal library that **bypasses git
  hooks**, which would silently disable the gitleaks pre-commit hook in this
  repo. `dotpush` uses real git, so the hook runs.
- **Secrets never enter this repo.** `.chezmoiignore` excludes the SSH,
  GnuPG, Canonical source-store, and local-LLM paths, `.gitignore` blocks
  common secret file patterns, and gitleaks scans every commit.
- **`~/.config/fish/vars.fish` is unmanaged on purpose.** Put machine-local
  fish variables there; `config.fish` sources it if it exists.
- **`[credential] helper = store` writes git credentials to
  `~/.git-credentials` in plain text.** That is a deliberate trade-off for
  headless use; be aware of it on shared machines.

### Local checks

```fish
cddot
pre-commit run --all-files
```

To see what a template renders to without applying anything:

```fish
chezmoi execute-template --file dot_config/bash/shortcuts.sh.tmpl
chezmoi cat ~/.config/git/config
```

To diagnose a broken setup:

```fish
chezmoi doctor
```
