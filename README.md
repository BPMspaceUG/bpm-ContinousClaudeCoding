# bpm-ContinousClaudeCoding

A wrapper for `continuous-claude` that automatically loads default and project-specific rules files.

## What `ccc` does

1. **Looks for global rules file**: `/etc/continuous-claude-defaultrules.md` (system) or `~/.continuous-claude-defaultrules.md` (user)
2. **Looks for project rules file**: `./continuous-claude-projectrules.md` in current directory
3. **Shows status**: `[INFO]` if found, `[WARNING]` if not found
4. **Starts continuous-claude** with found rules as `--notes-file` parameters
5. **Passes all your arguments** to continuous-claude (e.g. `ccc "fix bug"` → `continuous-claude ... "fix bug"`)

## Features

- **`ccc` command**: Shortcut for `continuous-claude` with automatic rules loading
- **Two-tier rules system**:
  - **Default rules**: Global rules applied to all sessions
  - **Project rules**: Project-specific rules in the current directory
- **Visual feedback**: INFO/WARNING messages show which rules are loaded
- **Flexible installation**: User-only or system-wide

## Installation

### Prerequisites

- `continuous-claude` must be installed and available in PATH
- Bash shell

### Quick Install

```bash
git clone https://github.com/BPMspaceUG/bpm-ContinousClaudeCoding.git
cd bpm-ContinousClaudeCoding
chmod +x install.sh
./install.sh
```

### Installation Options

#### User-only (no sudo required)
```bash
./install.sh --user
```
- Installs to `~/.bashrc`
- Default rules: `~/.continuous-claude-defaultrules.md`

#### System-wide (all users)
```bash
./install.sh --system
```
- Installs to `/etc/profile.d/continuous-claude.sh`
- Default rules: `/etc/continuous-claude-defaultrules.md`
- Requires sudo

## Usage

```bash
# Run continuous-claude with automatic rules loading
ccc

# Run with a specific prompt
ccc "your prompt here"

# Pass additional arguments
ccc --model opus "your prompt"
```

### Issue Shortcuts

Work on GitHub issues directly by passing issue numbers:

```bash
# Work on a single issue
ccc 2                    # Expands to: -p "work on issue 2"

# Work on two issues (uses "and")
ccc 2,7                  # Expands to: -p "work on issues 2 and 7"

# Work on multiple issues (comma-separated with "and" before last)
ccc 2,7,15               # Expands to: -p "work on issues 2, 7, and 15"

# Add context to issue work (merged with colon)
ccc 2 "focus on tests"   # Expands to: -p "work on issue 2: focus on tests"
```

### Open Issues Shortcut

Work on all open issues in the repository:

```bash
# List and work on all open issues
ccc open                 # Expands to: -p "list all open issues and then work on them"

# With additional context (merged with colon)
ccc open "prioritize bugs"  # Expands to: -p "list all open issues and then work on them: prioritize bugs"
```

### Output Example

```
[INFO] Using default rules: /etc/continuous-claude-defaultrules.md
[WARNING] Project rules NOT FOUND: /home/user/myproject/continuous-claude-projectrules.md
```

Or when both files exist:

```
[INFO] Using default rules: /etc/continuous-claude-defaultrules.md
[INFO] Using project rules: /home/user/myproject/continuous-claude-projectrules.md
```

## Rules Files

### Default Rules

Located at:
- **User install**: `~/.continuous-claude-defaultrules.md`
- **System install**: `/etc/continuous-claude-defaultrules.md`

Contains global rules that apply to all continuous-claude sessions.

### Project Rules

Create a file named `continuous-claude-projectrules.md` in your project directory.

Contains project-specific instructions, coding standards, and context.

## How It Works

The `ccc` function:

1. Checks for default rules file (system-wide or user-specific)
2. Checks for project rules file in current directory
3. Displays INFO (found) or WARNING (not found) for each
4. Calls `continuous-claude` with `--notes-file` arguments for found rules
5. Always adds `--disable-commits -m 100` flags

### Generated Command

```bash
continuous-claude --notes-file /etc/continuous-claude-defaultrules.md \
                  --notes-file ./continuous-claude-projectrules.md \
                  --disable-commits -m 100 "$@"
```

## File Structure

```
bpm-ContinousClaudeCoding/
├── README.md
├── install.sh              # Installation script
└── src/
    └── continuous-claude.sh    # The ccc function
```

## Uninstall

### User installation
Remove the ccc function block from `~/.bashrc`

### System installation
```bash
sudo rm /etc/profile.d/continuous-claude.sh
# Optionally remove rules file:
sudo rm /etc/continuous-claude-defaultrules.md
```

## License

MIT

## Author

BPMspace UG
