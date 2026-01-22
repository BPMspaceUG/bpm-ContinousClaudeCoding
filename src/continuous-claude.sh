# continuous-claude wrapper function (ccc)
# Source: https://github.com/BPMspaceUG/bpm-ContinousClaudeCoding
#
# This function wraps 'continuous-claude' with automatic rules file loading:
# - Default rules: /etc/continuous-claude-defaultrules.md (system-wide)
#                  OR ~/continuous-claude-defaultrules.md (user-only)
# - Project rules: ./continuous-claude-projectrules.md (current directory)
# - Auto-detects GitHub owner/repo from git remote

ccc() {
  # Check if continuous-claude is available
  if ! command -v continuous-claude >/dev/null 2>&1; then
    printf '\033[1;31m[ERROR]\033[0m continuous-claude not found in PATH\n' >&2
    printf 'Install it from: https://github.com/anthropics/claude-code\n' >&2
    return 1
  fi

  # Use local variables to avoid polluting shell environment
  local default_rules project_rules generated_prompt user_prompt
  local -a notes_args=()
  local -a remaining_args=()

  # Parse arguments for issue shortcuts and prompt merging
  generated_prompt=""
  user_prompt=""

  # Process arguments to extract -p flag value and detect shortcuts
  # We need to preserve all flags and their values, only extracting -p for merging
  local -a args_copy=("$@")
  local i=0 first_positional="" first_positional_idx=-1

  while (( i < ${#args_copy[@]} )); do
    local arg="${args_copy[$i]}"
    case "$arg" in
      -p|--prompt)
        # Extract prompt value for merging, but preserve it for passthrough if no shortcut
        if (( i + 1 < ${#args_copy[@]} )); then
          user_prompt="${args_copy[$((i + 1))]}"
          # Store both flag and its value in remaining_args for passthrough
          remaining_args+=("$arg" "${args_copy[$((i + 1))]}")
          i=$((i + 2))
        else
          remaining_args+=("$arg")
          i=$((i + 1))
        fi
        ;;
      -m|--max-runs|--max-cost|--max-duration|--owner|--repo|--git-branch-prefix|--merge-strategy|--notes-file|--worktree|--worktree-base-dir|--completion-signal|--completion-threshold|-r|--review-prompt|--ci-retry-max|--model)
        # Known flags that take a value - preserve both flag and value
        # Includes both continuous-claude flags and claude-code flags that might be passed through
        if (( i + 1 < ${#args_copy[@]} )); then
          remaining_args+=("$arg" "${args_copy[$((i + 1))]}")
          i=$((i + 2))
        else
          remaining_args+=("$arg")
          i=$((i + 1))
        fi
        ;;
      -*)
        # Other flag arguments - keep them
        remaining_args+=("$arg")
        i=$((i + 1))
        ;;
      *)
        # Positional argument
        if [ -z "$first_positional" ]; then
          first_positional="$arg"
          first_positional_idx=${#remaining_args[@]}
        fi
        remaining_args+=("$arg")
        i=$((i + 1))
        ;;
    esac
  done

  # Helper function to remove element at index from remaining_args
  remove_first_positional() {
    local -a new_remaining=()
    local j
    for ((j=0; j<${#remaining_args[@]}; j++)); do
      if (( j != first_positional_idx )); then
        new_remaining+=("${remaining_args[$j]}")
      fi
    done
    remaining_args=("${new_remaining[@]}")
  }

  # Helper function to remove -p/--prompt and their values from remaining_args
  # Used when shortcut is detected and we need to merge user's prompt with generated prompt
  # Note: During initial parse, -p/--prompt always consume next arg as value, so we do the same here
  remove_prompt_flags() {
    local -a new_remaining=()
    local j=0
    while (( j < ${#remaining_args[@]} )); do
      if [[ "${remaining_args[$j]}" == "-p" || "${remaining_args[$j]}" == "--prompt" ]]; then
        # Skip -p/--prompt flag
        j=$((j + 1))
        # Also skip value if present (consistent with initial parse which always consumes next token)
        if (( j < ${#remaining_args[@]} )); then
          j=$((j + 1))
        fi
      else
        new_remaining+=("${remaining_args[$j]}")
        j=$((j + 1))
      fi
    done
    remaining_args=("${new_remaining[@]}")
  }

  # Helper function to find and remove first positional (non-flag) argument from remaining_args
  # Returns the value via the global variable 'found_positional'
  # Skips values of known value-taking flags to avoid picking them up as positional args
  find_and_remove_first_positional() {
    found_positional=""
    local -a new_remaining=()
    local j=0 found=0 skip_next=0
    while (( j < ${#remaining_args[@]} )); do
      local current="${remaining_args[$j]}"
      # If previous arg was a value-taking flag, skip this (it's the flag's value)
      if (( skip_next )); then
        new_remaining+=("$current")
        skip_next=0
        j=$((j + 1))
        continue
      fi
      # Check if this is a known value-taking flag
      # Note: -p/--prompt are already removed by remove_prompt_flags() before this is called
      case "$current" in
        -p|--prompt|-m|--max-runs|--max-cost|--max-duration|--owner|--repo|--git-branch-prefix|--merge-strategy|--notes-file|--worktree|--worktree-base-dir|--completion-signal|--completion-threshold|-r|--review-prompt|--ci-retry-max|--model)
          new_remaining+=("$current")
          skip_next=1
          j=$((j + 1))
          ;;
        -*)
          # Other flag (doesn't take value)
          new_remaining+=("$current")
          j=$((j + 1))
          ;;
        *)
          # Positional argument
          if (( !found )); then
            found_positional="$current"
            found=1
          else
            new_remaining+=("$current")
          fi
          j=$((j + 1))
          ;;
      esac
    done
    remaining_args=("${new_remaining[@]}")
  }
  local found_positional=""

  # Check for issue number shortcut (e.g., "2" or "2,7,15")
  if [[ "$first_positional" =~ ^[0-9]+(,[0-9]+)*$ ]]; then
    # Remove the issue numbers from remaining_args
    remove_first_positional
    # Remove any existing -p flag since we'll merge it with generated prompt
    remove_prompt_flags

    # Parse issue numbers
    local issues_str="$first_positional"
    local -a issues
    IFS=',' read -ra issues <<< "$issues_str"

    # Generate prompt based on number of issues
    if [ ${#issues[@]} -eq 1 ]; then
      generated_prompt="work on issue ${issues[0]}"
    elif [ ${#issues[@]} -eq 2 ]; then
      generated_prompt="work on issues ${issues[0]} and ${issues[1]}"
    else
      # Multiple issues: "work on issues 1, 2, and 3"
      local issues_text="${issues[0]}"
      local k
      for ((k=1; k<${#issues[@]}-1; k++)); do
        issues_text="$issues_text, ${issues[$k]}"
      done
      issues_text="$issues_text, and ${issues[$((${#issues[@]}-1))]}"
      generated_prompt="work on issues $issues_text"
    fi

    # Find first positional (non-flag) argument to merge with prompt
    find_and_remove_first_positional
    if [ -n "$found_positional" ]; then
      user_prompt="${user_prompt:+$user_prompt }$found_positional"
    fi
  # Check for "open" keyword
  elif [ "$first_positional" = "open" ]; then
    # Remove "open" from remaining_args
    remove_first_positional
    # Remove any existing -p flag since we'll merge it with generated prompt
    remove_prompt_flags
    generated_prompt="list all open issues and then work on them"

    # Find first positional (non-flag) argument to merge with prompt
    find_and_remove_first_positional
    if [ -n "$found_positional" ]; then
      user_prompt="${user_prompt:+$user_prompt }$found_positional"
    fi
  fi

  # Determine default rules location based on installation type
  if [ -f "/etc/continuous-claude-defaultrules.md" ]; then
    default_rules="/etc/continuous-claude-defaultrules.md"
  else
    default_rules="$HOME/continuous-claude-defaultrules.md"
  fi
  project_rules="$PWD/continuous-claude-projectrules.md"

  # Check default rules file
  if [ -f "$default_rules" ]; then
    printf '\033[1;34m[INFO]\033[0m Using default rules: %s\n' "$default_rules"
    notes_args+=("--notes-file" "$default_rules")
  else
    printf '\033[1;33m[WARNING]\033[0m Default rules NOT FOUND: %s\n' "$default_rules"
  fi

  # Check project-specific rules file in current directory
  if [ -f "$project_rules" ]; then
    printf '\033[1;34m[INFO]\033[0m Using project rules: %s\n' "$project_rules"
    notes_args+=("--notes-file" "$project_rules")
  else
    printf '\033[1;33m[WARNING]\033[0m Project rules NOT FOUND: %s\n' "$project_rules"
  fi

  # Auto-detect GitHub owner/repo from git remote if not already specified
  local git_owner="" git_repo=""
  local has_owner=0 has_repo=0

  # Check if --owner or --repo already provided in args (supports both --owner value and --owner=value)
  local check_arg
  for check_arg in "$@"; do
    case "$check_arg" in
      --owner|--owner=*) has_owner=1 ;;
      --repo|--repo=*) has_repo=1 ;;
    esac
  done

  # Extract owner/repo from git remote if in a git repo and flags not provided
  if (( !has_owner || !has_repo )); then
    local git_remote
    git_remote=$(git remote get-url origin 2>/dev/null) || true
    if [ -n "$git_remote" ]; then
      # Parse GitHub URL (supports both HTTPS and SSH formats)
      # HTTPS: https://github.com/owner/repo.git
      # SSH: git@github.com:owner/repo.git
      if [[ "$git_remote" =~ github\.com[:/]([^/]+)/([^/.]+)(\.git)?$ ]]; then
        git_owner="${BASH_REMATCH[1]}"
        git_repo="${BASH_REMATCH[2]}"
        printf '\033[1;34m[INFO]\033[0m Auto-detected GitHub repo: %s/%s\n' "$git_owner" "$git_repo"
      fi
    fi
  fi

  # Build final command
  local -a final_args=("${notes_args[@]}" "--disable-commits" "-m" "100")

  # Add auto-detected owner/repo if available and not already specified
  if (( !has_owner )) && [ -n "$git_owner" ]; then
    final_args+=("--owner" "$git_owner")
  fi
  if (( !has_repo )) && [ -n "$git_repo" ]; then
    final_args+=("--repo" "$git_repo")
  fi

  # Add generated prompt with optional user prompt
  if [ -n "$generated_prompt" ]; then
    local full_prompt="$generated_prompt"
    if [ -n "$user_prompt" ]; then
      full_prompt="$full_prompt: $user_prompt"
    fi
    final_args+=("-p" "$full_prompt")
    final_args+=("${remaining_args[@]}")
  else
    # No shortcut used, pass all original arguments
    final_args+=("$@")
  fi

  continuous-claude "${final_args[@]}"
}
