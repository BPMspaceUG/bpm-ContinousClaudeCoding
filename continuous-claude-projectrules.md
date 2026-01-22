# Project Rules for ccc (continuous-claude wrapper)

## Installation Format

Installation MUST always follow the ico-reference format:

```bash
# One-time usage (loads function into current shell)
source <(curl -fsSL https://raw.githubusercontent.com/BPMspaceUG/bpm-ContinousClaudeCoding/main/src/continuous-claude.sh)

# Permanent user installation (~/.bashrc)
curl -fsSL https://raw.githubusercontent.com/BPMspaceUG/bpm-ContinousClaudeCoding/main/install.sh | bash -s -- --user

# Permanent system installation (/etc/profile.d/)
curl -fsSL https://raw.githubusercontent.com/BPMspaceUG/bpm-ContinousClaudeCoding/main/install.sh | bash -s -- --system
```

Reference: https://github.com/International-Certification-Org/ico-claude-global-agent-skill-library

## README Structure

The README MUST contain:
- Curl-based installation commands (not `git clone`)
- Man-page style usage section with all commands
- Tables for input/output mapping for shortcuts
- Complete examples for all features

## Bash Script Rules

- All variables must be `local` (no shell pollution)
- Colored output with `printf` and ANSI codes
- `set -euo pipefail` in scripts (not in sourced functions)
- Error handling with meaningful messages
- Use shellcheck-compliant code

## Feature Documentation

Every feature MUST be documented with:
- Source code line reference where applicable
- Input/output table
- At least 2 examples

## Testing

After changes to `src/continuous-claude.sh`:
```bash
source src/continuous-claude.sh  # Load function in current shell
ccc                               # Test basic functionality
ccc 1                             # Test issue shortcut
ccc 1,2                           # Test multiple issues
ccc open                          # Test open shortcut
ccc 1 "extra context"             # Test prompt merging
```

## Language

- All GitHub issues MUST be written in English
- All code comments MUST be in English
- All documentation (README, etc.) MUST be in English

## Git Workflow

- Do NOT commit directly in continuous-claude sessions (--disable-commits is enforced)
- Changes are committed by the automation after review
- Always work from the main branch unless specified

## GitHub API Calls

BEFORE making any GitHub API calls:
1. The ccc wrapper auto-detects owner/repo from git remote
2. If --owner/--repo are passed explicitly, they take precedence
3. Never assume owner from authenticated user - always check git config
