# ccc - continuous-claude wrapper

[![Version](https://img.shields.io/badge/version-260122--2111-blue.svg)](https://github.com/BPMspaceUG/bpm-ContinousClaudeCoding)

A shell function that wraps `continuous-claude` with automatic rules file loading and GitHub issue shortcuts.

## Installation

### One-time Usage

Load the function directly into your current shell:

```bash
source <(curl -fsSL https://raw.githubusercontent.com/BPMspaceUG/bpm-ContinousClaudeCoding/main/src/continuous-claude.sh)
```

### Permanent Installation

#### User Installation (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/BPMspaceUG/bpm-ContinousClaudeCoding/main/install.sh | bash -s -- --user
```

- Installs to `~/.bashrc`
- Default rules: `~/continuous-claude-defaultrules.md`
- No sudo required

#### System Installation

```bash
curl -fsSL https://raw.githubusercontent.com/BPMspaceUG/bpm-ContinousClaudeCoding/main/install.sh | bash -s -- --system
```

- Installs to `/etc/profile.d/continuous-claude.sh`
- Default rules: `/etc/continuous-claude-defaultrules.md`
- Requires sudo

## Usage

### NAME

`ccc` - continuous-claude wrapper with automatic rules loading and issue shortcuts

### SYNOPSIS

```
ccc [OPTIONS] [PROMPT]
ccc [OPTIONS] ISSUE_NUMBER[,ISSUE_NUMBER...] [CONTEXT]
ccc [OPTIONS] open [CONTEXT]
ccc --version
ccc update [--check] [--ccc] [--cc] [--user|--system]
```

### DESCRIPTION

Wraps `continuous-claude` with automatic loading of default and project rules files.
Supports shortcuts for working on GitHub issues.

### OPTIONS

```
-p, --prompt TEXT            Custom prompt (can be combined with shortcuts)
-m, --max-runs N             Maximum iterations (default: 100)
--max-cost COST              Maximum cost limit
--max-duration DURATION      Maximum duration limit
--model MODEL                Model to use (e.g., opus, sonnet)
--owner OWNER                GitHub repository owner (auto-detected from git)
--repo REPO                  GitHub repository name (auto-detected from git)
--git-branch-prefix PREFIX   Prefix for git branches
--merge-strategy STRATEGY    Merge strategy to use
--notes-file FILE            Additional notes file to load
--worktree PATH              Git worktree path
--worktree-base-dir DIR      Base directory for worktrees
--completion-signal SIGNAL   Signal for completion
--completion-threshold N     Threshold for completion
-r, --review-prompt TEXT     Review prompt
--ci-retry-max N             Maximum CI retries
--disable-commits            Disable automatic commits (always enabled)
```

All `continuous-claude` flags are passed through.

### EXAMPLES

```bash
ccc                              # Run with rules files only
ccc "prompt text"                # Run with custom prompt
ccc 5                            # Work on issue #5
ccc 1,9                          # Work on issues #1 and #9
ccc 2,5,8                        # Work on issues #2, #5, and #8
ccc open                         # List and work on all open issues
ccc 3 "focus on tests"           # Issue #3 with additional context
ccc open "only bugs"             # Open issues with context
ccc 3 -p "focus on tests"        # Same as above, using -p flag
ccc --model opus "prompt"        # With specific model
```

## Features

### Issue Shortcuts

Work on GitHub issues by passing issue numbers:

| Input | Generated Prompt |
|-------|------------------|
| `ccc 2` | `-p "work on issue 2"` |
| `ccc 2,7` | `-p "work on issues 2 and 7"` |
| `ccc 2,7,15` | `-p "work on issues 2, 7, and 15"` |

### Open Issues Shortcut

| Input | Generated Prompt |
|-------|------------------|
| `ccc open` | `-p "list all open issues and then work on them"` |

### Prompt Merging

Additional context is appended with a colon:

| Input | Generated Prompt |
|-------|------------------|
| `ccc 2 "focus on tests"` | `-p "work on issue 2: focus on tests"` |
| `ccc open "prioritize bugs"` | `-p "list all open issues and then work on them: prioritize bugs"` |
| `ccc 2 -p "only unit tests"` | `-p "work on issue 2: only unit tests"` |
| `ccc open --prompt "bugs first"` | `-p "list all open issues and then work on them: bugs first"` |

Both positional and flag-based prompts work with all shortcuts.

### Auto-detected GitHub Repository

The wrapper automatically detects `--owner` and `--repo` from your git remote:

```
[INFO] Auto-detected GitHub repo: BPMspaceUG/bpm-ContinousClaudeCoding
```

This prevents API errors from using the wrong repository owner.

### Rules Files

Two-tier rules system:

| File | Location | Purpose |
|------|----------|---------|
| Default rules | `/etc/continuous-claude-defaultrules.md` (system) | Global rules for all sessions |
|               | `~/continuous-claude-defaultrules.md` (user) | |
| Project rules | `./continuous-claude-projectrules.md` | Project-specific rules |

### Fixed Flags

Always added to every invocation:
- `--disable-commits` - Prevents automatic commits
- `-m 100` - Maximum 100 iterations

### Flag Passthrough

These flags are correctly passed through to `continuous-claude`:

`-m`, `--max-runs`, `--max-cost`, `--max-duration`, `--owner`, `--repo`, `--git-branch-prefix`, `--merge-strategy`, `--notes-file`, `--worktree`, `--worktree-base-dir`, `--completion-signal`, `--completion-threshold`, `-r`, `--review-prompt`, `--ci-retry-max`, `--model`

## Output

```
[INFO] Using default rules: /etc/continuous-claude-defaultrules.md
[INFO] Using project rules: /home/user/myproject/continuous-claude-projectrules.md
[INFO] Auto-detected GitHub repo: owner/repo
```

Or when files are missing:

```
[WARNING] Default rules NOT FOUND: ~/continuous-claude-defaultrules.md
[WARNING] Project rules NOT FOUND: ./continuous-claude-projectrules.md
```

## Prerequisites

- `continuous-claude` must be installed and in PATH
- Bash shell
- Git (for auto-detection of owner/repo)

## Uninstall

### User Installation

Remove the ccc function block from `~/.bashrc` (between `# <<<CCC_START>>>` and `# <<<CCC_END>>>` markers)

### System Installation

```bash
sudo rm /etc/profile.d/continuous-claude.sh
# Optionally remove rules file:
sudo rm /etc/continuous-claude-defaultrules.md
```

## License

MIT

## Author

BPMspace UG
