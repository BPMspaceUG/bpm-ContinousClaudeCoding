# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Bash wrapper (`ccc`) for `continuous-claude` that automatically loads default and project-specific rules files via `--notes-file` parameters.

## Architecture

- **`src/continuous-claude.sh`**: The `ccc` shell function that gets sourced into user's shell
- **`install.sh`**: Installation script supporting user-only (`--user`) or system-wide (`--system`) installation

## How ccc Works

1. Checks for default rules at `/etc/continuous-claude-defaultrules.md` (system) or `~/.continuous-claude-defaultrules.md` (user)
2. Checks for project rules at `./continuous-claude-projectrules.md` in current directory
3. Builds `--notes-file` arguments for each found file
4. Calls `continuous-claude $NOTES_ARGS --disable-commits -m 100 "$@"`

## Testing Changes

After modifying `src/continuous-claude.sh`:
```bash
source src/continuous-claude.sh  # Load function in current shell
ccc                               # Test the function
```

For install.sh changes, test in a clean environment or use:
```bash
./install.sh --user   # Test user installation
./install.sh --system # Test system installation (requires sudo)
```
