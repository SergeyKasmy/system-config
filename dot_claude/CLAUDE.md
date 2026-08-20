## Terms

- "starting directory": the directory the agent was launched in - not wherever it may cd into during the session. If I start you in `/etc`, changes to `/etc` are in-scope even though it persists a reboot.

## Rules

- **When you want to search for something on the user's filesystem (not in the starting directory), don't!** Instead ask the user if they have it and if they may point you to it.
- **When searching (whether in the starting directory or system-wide), prefer faster/more targeted tools over the defaults, in this priority order:**
    1. `locate`, if it's available and fits the task
    2. `fd`, if `locate` isn't available or doesn't fit the task (instead of `find`)
    3. `rg` instead of `grep`, always
    4. `dua` instead of `du`.
    5. If neither `locate`, `fd`, `rg`, or `dua` is available, fall back to `find`, `grep`, and `du` respectively - without asking.

    When doing a system-wide search with `fd`, always exclude these directories:
    - `/.root`
    - `/.snapshots`
    - `/home/.snapshots`

- **Whenever you leave comments in code or config files, prefer explaining WHY something is being done over WHAT is being done.** The exception is genuinely non-obvious code (e.g. bit-shifting, clever math, obscure APIs)
where explaining WHAT it does is itself valuable — in those cases, WHAT and WHY can both be worth a comment. Example:

```python
## BAD!
Path("foo.txt").write_text(result) # save result to foo.txt

## GOOD!
Path("foo.txt").write_text(result) # keep result for future use. It might be needed to confirm the result is correct.
```

- **DO NOT make any changes outside the starting directory that would persist a reboot (e.g. installing/removing packages, editing config files elsewhere on disk, enabling/disabling services at boot) without user's permission.**
Changes inside the starting directory are always fine, regardless of whether they persist a reboot. Outside the starting directory,
actions that don't survive a reboot (e.g. starting/stopping a running service, setting env vars for the current session, writing to `/tmp`) are also fine without asking. If you want to make a change outside
the starting directory that would persist a reboot, you MUST ask the user for permission first. Permission to do something once doesn't mean you can do this again. It's CRITICAL that you ask for permission each time.
Before any Write/Edit/desctructive bash tool call outside the starting directory, state the path and ask for permission, even if it seems obviously safe.

Examples of things that are NOT ALLOWED WITHOUT USER PERMISSION:
- Editing user configs, including systemd drop-ins.
- Running destructive commands that affect files outside the starting directory, including but not limited to `rm`, `tee`, or `sed -i`.

- **DO NOT use sudo, ever.** `sudo` requires a working pty and doesn't work from your tool call. Calling `sudo` will block forever AND lock my user account.
Whenever you require something to be run as root, ASK THE USER to run the command for you AND explain what the command does.
This applies everywhere, as this is a technical constraint, including the starting directory.

- **`jj` is the VCS of choice.** When doing anything VCS related (e.g. commiting, reading commit logs), check if the repo is a `jj` repo first, and fallback to `git` only if it isn't.
In `jj` repos prefer to use `jj` over `git` wherever possible, and fallback to `git` only if `jj` explicitely doesn't yet provide the required functionality (e.g. submodules).
