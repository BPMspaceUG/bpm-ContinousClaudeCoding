# Shared Task Notes

## Current Status (2026-01-22)

All three open issues (#8, #11, #12) have been implemented, tested, and approved by Codex. Local changes are ready for commit and push.

## Issues Status

| Issue | Title | Status | Approvals |
|-------|-------|--------|-----------|
| #8 | README revision + bug fixes + direct prompt | DONE | Implementation, Test Design, Test Results (all Codex) |
| #11 | Version display (YYMMDD-HHMM) | DONE | Implementation, Test Design, Test Results (all Codex) |
| #12 | Update command | DONE | Implementation, Test Design, Test Results (all Codex) |

## Modified Files (uncommitted)

```
M README.md                    # Version badge, ico-format install, man-page docs
M install.sh                   # Downloads source via curl (not local paths)
M src/continuous-claude.sh     # All fixes + features, version 260122-2111
```

## Features Implemented

1. **Issue shortcuts**: `ccc 8` -> `-p "work on issue 8"`
2. **Multi-issue**: `ccc 1,2,3` -> `-p "work on issues 1, 2, and 3"` (Oxford comma)
3. **Open shortcut**: `ccc open` -> `-p "list all open issues..."`
4. **Direct prompt**: `ccc "my prompt"` -> `-p "my prompt"`
5. **Version display**: `ccc --version`, version shown on every invocation
6. **Update command**: `ccc update [--check] [--ccc] [--cc] [--user|--system]`
7. **Default rules path**: Fixed to `~/continuous-claude-defaultrules.md` (no dot)
8. **Install script**: Now downloads source via curl (works when piped)

## Next Steps

1. **Automation commits and pushes changes**
2. User reinstalls and tests:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/BPMspaceUG/bpm-ContinousClaudeCoding/main/install.sh | bash -s -- --user
   source ~/.bashrc
   ccc --version        # Should show 260122-2111
   ccc "test prompt"    # Should pass -p "test prompt"
   ccc 8                # Should pass -p "work on issue 8"
   ccc update --check   # Should show versions
   ```
3. Close Issues #8, #11, #12 after user verification

## Version

Current version: `260122-2111`
