---
name: split-megacommit
description: >-
  Split one large Jujutsu (jj) commit in this chezmoi dotfiles repo into several
  small, single-purpose commits, each titled "program: what changed". Use
  whenever the user has lumped many unrelated edits into a single commit (a
  "mega-commit") and wants them separated — phrasings include "split this
  commit", "break up my commit", "un-squash", "I forgot to commit separately",
  "too many things in one commit", or "make these into separate commits". Also
  trigger when the user points at a jj commit that bundles changes to multiple
  tools (hypr, fish, waybar, nvim, zellij, scripts, etc.) and asks for cleaner
  history.
---

# Split a mega-commit into targeted commits

The user often dumps many unrelated changes into one commit. This skill rewrites
that commit into a stack of small commits, each doing exactly one thing, ordered
so no commit depends on a later one. Read `CLAUDE.md` for the tool/directory map
before starting.

Bookmarks are out of scope — the user manages those manually. Do not move,
create, or delete any bookmark.

## Mental model

jj auto-snapshots the working copy and every operation is reversible via
`jj undo`. So the safe strategy is: rebuild the desired stack beneath the
mega-commit, verify the result is byte-identical to the original, and only then
discard the original. Hunk-level splitting is done by **reconstructing exact file
contents** at each step (not by applying patches): you know each file's content
at its base (pre-change) state and at the mega-commit, so each intermediate
commit gets the file written out at its exact cumulative state. No patch fuzz.

## Procedure

### 1. Identify the commit and capture state

- Default target is `@`; if the user names a revision, use that. Call it `MEGA`.
- `jj diff -r MEGA --summary` for the add/modify/delete list.
- Capture each changed file's final content: `jj file show -r MEGA <path>`
  (absent for deleted). Base content is read in step 6, off the empty inserted
  commit, so this works regardless of how many parents `MEGA` has.
- Binary files (images, fonts) can't be hunk-split — assign each wholesale to
  one commit.

### 2. Decompose into single-purpose groups

Partition all changes (including new files and deletions) into logical groups.
**One group = one commit = one idea.** A group may span files; one file may be
split across groups.

- **Keep new API together with its use.** When a change both introduces new API
  (e.g. a new Hyprland Lua helper) and uses it, put both in one commit. A
  genuinely standalone, reusable library addition may be its own commit, but
  only if it stands alone and is ordered before any consumer.
- **Separate independent features**, even within one file.
- **Never make a comment-only commit.** Edits that only touch comments,
  docstrings, or TODO notes aren't a standalone change — fold each into a code
  commit touching the same file or the closest related code (e.g. a TODO tweak
  in `lsp.lua` rides with another `nvim:` change to that file). If nothing in
  the split relates, attach it to the nearest commit for that tool rather than
  isolating it.
- **Group by intent, not by file.**

### 3. Order for clean reversibility

No commit may depend on a future commit; dependencies always point backward
(later may rely on earlier). For each group note what it *defines* (files,
functions, config keys, scripts) and what it *references* from another group;
place definitions before their uses. A prerequisite refactor comes before the
features built on it.

If two groups reference each other so that no ordering avoids a forward
dependency, the changes are genuinely intertwined — **stop and ask the user**,
showing the hunks involved, rather than guessing or silently merging.

### 4. Commit messages

Format: `program: what changed`, lowercase after the colon, no trailing period,
present-tense imperative ("add", "show", "correct", "migrate"). Be specific
about what and how.

`program` from the path (see `CLAUDE.md` for the full table):
`dot_config/<tool>/...` → `<tool>` (hypr for `exact_hypr`); `dot_gitconfig.tmpl`
→ `git`; editing an existing `dot_local/bin/<script>` → `<script>`.

**Drop the prefix for brand-new tools and standalone scripts.** "Brand-new"
means it didn't exist before this commit — that introducing commit uses a bare,
capitalized sentence (`Add jj config`, `Add hyprlock-reset script`). Once a tool
exists, later edits use the `tool:` prefix.

**Prefer the resulting behavior over "fix."** When a short description of what
the change now does reads clearly, use it — `fish: preserve path in bak/unbak
aliases`, not `fish: fix bak/unbak`. Fall back to "fix …" only when no such
phrasing is clearer. Use single quotes for literal names.

**One primary change per subject.** If a commit also carries a minor incidental
cleanup unrelated to its main point (a leftover debug print, stray whitespace, a
dead line), keep it out of the subject and record it in a body paragraph with a
second `-m`:
```
jj describe -m "nvim: fix inlay hint bufnr typo" -m "And remove leftover debug print"
```

Examples:
```
fish: add 'dev' zellij alias
waybar: show active window icon
hyprland: change compose key to Menu
hyprland: correct J/K keybind wrong order
hyprland: migrate Iter adapters to tbl utils, add .new & .clone in the process
Add jj config
Add hyprlock-reset script
```

### 5. Present the plan

Show the ordered plan as a numbered `message — files/hunks` list, and note it's
reversible with `jj undo`. Proceed without waiting, unless step 3 found an
intertwined group needing a decision — then wait for the answer.

### 6. Rebuild the stack

Insert the new commits *before* `MEGA` so its parent(s) are inherited
automatically — this also covers merge commits (multiple parents).

```
jj new -B MEGA       # empty commit inserted before MEGA, on its parent(s); @ tree == base
```
The working copy now shows the base tree; read base content for the changed
files here (added files are absent). Then for each group `k` in order:
1. For every file the group touches, write its **cumulative** content — base
   content with all hunks from groups `1..k` applied (create/delete files at the
   group that introduces/removes them). The tree is then exactly "base + 1..k".
2. `jj describe -m "program: what changed"`
3. `jj new -B MEGA` to insert the next commit (skip after the last group).

Each insertion chains onto the previous one and floats `MEGA` upward, leaving it
empty. The original mega-commit description is discarded; each commit gets its own.

### 7. Verify, then finalize

`MEGA` has floated to the top and should now be empty. Verify it carries no
changes:
```
jj diff -r MEGA --summary
```
This must be **empty**. If non-empty, a hunk was missed or misplaced — do **not**
abandon anything; report and fix. Once empty:
```
jj abandon MEGA      # auto-rebases any descendants onto the new tip
jj log
```
`@` is left on the last real commit; run `jj new` if a fresh empty working copy
is wanted.

## Safety notes

- Never run `chezmoi apply`; this skill only restructures history. `.tmpl` files
  are reconstructed as plain text — do not render them.
- Do not abandon `MEGA` until step 7's diff is empty. The whole operation is
  undoable with `jj undo` / `jj op log`.
