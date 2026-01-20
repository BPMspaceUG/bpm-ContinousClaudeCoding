# continuous-claude wrapper function (ccc)
# Source: https://github.com/BPMspaceUG/bpm-ContinousClaudeCoding
#
# This function wraps 'continuous-claude' with automatic rules file loading:
# - Default rules: /etc/continuous-claude-defaultrules.md (system-wide)
#                  OR ~/.continuous-claude-defaultrules.md (user-only)
# - Project rules: ./continuous-claude-projectrules.md (current directory)

ccc() {
  # Determine default rules location based on installation type
  if [ -f "/etc/continuous-claude-defaultrules.md" ]; then
    DEFAULT_RULES="/etc/continuous-claude-defaultrules.md"
  else
    DEFAULT_RULES="$HOME/.continuous-claude-defaultrules.md"
  fi
  PROJECT_RULES="./continuous-claude-projectrules.md"

  NOTES_ARGS=""

  # Check default rules file
  if [ -f "$DEFAULT_RULES" ]; then
    printf '\033[1;34m[INFO]\033[0m Using default rules: %s\n' "$DEFAULT_RULES"
    NOTES_ARGS="--notes-file $DEFAULT_RULES"
  else
    printf '\033[1;33m[WARNING]\033[0m Default rules NOT FOUND: %s\n' "$DEFAULT_RULES"
  fi

  # Check project-specific rules file in current directory
  if [ -f "$PROJECT_RULES" ]; then
    printf '\033[1;34m[INFO]\033[0m Using project rules: %s\n' "$(pwd)/continuous-claude-projectrules.md"
    NOTES_ARGS="$NOTES_ARGS --notes-file $PROJECT_RULES"
  else
    printf '\033[1;33m[WARNING]\033[0m Project rules NOT FOUND: %s\n' "$(pwd)/continuous-claude-projectrules.md"
  fi

  continuous-claude $NOTES_ARGS --disable-commits -m 100 "$@"
}
