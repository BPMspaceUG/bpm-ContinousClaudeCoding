#!/bin/bash
# install.sh - Install ccc (continuous-claude wrapper)
# Source: https://github.com/BPMspaceUG/bpm-ContinousClaudeCoding
# Wraps: https://github.com/AnandChowdhary/continuous-claude
#
# Designed to be piped from curl:
#   curl -fsSL https://raw.githubusercontent.com/BPMspaceUG/bpm-ContinousClaudeCoding/main/install.sh | bash -s -- --user

set -euo pipefail

CCC_VERSION="1.0.0"
GITHUB_RAW_URL="https://raw.githubusercontent.com/BPMspaceUG/bpm-ContinousClaudeCoding/main"
SOURCE_URL="$GITHUB_RAW_URL/src/continuous-claude.sh"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() { printf "${BLUE}[INFO]${NC} %s\n" "$1"; }
print_success() { printf "${GREEN}[SUCCESS]${NC} %s\n" "$1"; }
print_warning() { printf "${YELLOW}[WARNING]${NC} %s\n" "$1"; }
print_error() { printf "${RED}[ERROR]${NC} %s\n" "$1"; }

# Check for continuous-claude dependency
check_dependency() {
    if ! command -v continuous-claude >/dev/null 2>&1; then
        print_warning "continuous-claude not found in PATH"
        print_warning "Install it from: https://github.com/anthropics/claude-code"
        print_warning "ccc will not work until continuous-claude is installed"
        echo ""
    fi
}

show_usage() {
    echo "Usage: $0 [--user | --global | --all]"
    echo ""
    echo "Options:"
    echo "  --user      Install for current user only (~/.bashrc)"
    echo "  --global    Install system-wide for all users (/etc/profile.d/) - requires sudo"
    echo "  --system    Alias for --global (backwards compatibility)"
    echo "  --all       Install to both user and system locations"
    echo "  --version   Show version number"
    echo "  --help      Show this help message"
    echo ""
    echo "If no option is provided, you will be prompted to choose."
}

download_source() {
    local content
    content=$(curl -fsSL "$SOURCE_URL" 2>/dev/null) || {
        print_error "Failed to download source from: $SOURCE_URL"
        exit 3
    }
    echo "$content"
}

install_user() {
    print_info "Installing ccc v$CCC_VERSION for current user..."
    check_dependency

    # Copy function to user's bashrc
    BASHRC="$HOME/.bashrc"
    RULES_FILE="$HOME/continuous-claude-defaultrules.md"

    # Download source
    print_info "Downloading source from GitHub..."
    local source_content
    source_content=$(download_source)

    # Backup .bashrc before modification
    if [ -f "$BASHRC" ]; then
        cp "$BASHRC" "$BASHRC.bak"
        print_info "Backed up $BASHRC to $BASHRC.bak"
    fi

    # Remove old installation if exists
    # Handles both old format (ending with closing brace of ccc function) and new format (with markers)
    if grep -q "# ccc - continuous-claude wrapper" "$BASHRC" 2>/dev/null; then
        print_info "Removing previous installation..."
        # Single-pass awk that handles both formats:
        # - hdr=1: just saw header, check if next line is CCC_START (new format)
        # - If CCC_START immediately follows: remove until CCC_END (new format)
        # - Otherwise: remove until ^}$ (old format)
        # Note: in old format, line after header is function content (should be skipped)
        awk '
            /^# ccc - continuous-claude wrapper/ { hdr=1; next }
            hdr && /^# <<<CCC_START>>>$/ { inblock=1; mode="new"; hdr=0; next }
            hdr { inblock=1; mode="old"; hdr=0 }
            inblock && mode=="new" && /^# <<<CCC_END>>>$/ { inblock=0; mode=""; next }
            inblock && mode=="old" && /^}$/ { inblock=0; mode=""; next }
            inblock { next }
            { print }
        ' "$BASHRC" > "$BASHRC.tmp" && mv "$BASHRC.tmp" "$BASHRC"
    fi

    # Add start marker, function, and end marker
    {
        echo ""
        echo "# ccc - continuous-claude wrapper v$CCC_VERSION (installed by bpm-ContinousClaudeCoding)"
        echo "# <<<CCC_START>>>"
        echo "$source_content"
        echo "# <<<CCC_END>>>"
    } >> "$BASHRC"

    # Check if default rules file exists - warn if not
    if [ ! -f "$RULES_FILE" ]; then
        print_warning "Default rules file NOT FOUND: $RULES_FILE"
        print_warning "Create this file manually!"
    else
        print_info "Default rules file exists: $RULES_FILE"
    fi

    print_success "Installed ccc v$CCC_VERSION for user: $USER"
    print_info "Run 'source ~/.bashrc' or open a new terminal to use 'ccc'"
}

install_system() {
    print_info "Installing ccc v$CCC_VERSION system-wide (requires sudo)..."
    check_dependency

    # Check for sudo
    if ! sudo -v 2>/dev/null; then
        print_error "sudo access required for system-wide installation"
        exit 2
    fi

    PROFILE_SCRIPT="/etc/profile.d/continuous-claude.sh"
    RULES_FILE="/etc/continuous-claude-defaultrules.md"

    # Download source
    print_info "Downloading source from GitHub..."
    local source_content
    source_content=$(download_source)

    # Backup existing profile script if it exists
    if [ -f "$PROFILE_SCRIPT" ]; then
        sudo cp "$PROFILE_SCRIPT" "$PROFILE_SCRIPT.bak"
        print_info "Backed up $PROFILE_SCRIPT to $PROFILE_SCRIPT.bak"
    fi

    # Write downloaded content to profile.d
    echo "$source_content" | sudo tee "$PROFILE_SCRIPT" > /dev/null
    sudo chmod 644 "$PROFILE_SCRIPT"
    print_info "Installed shell function: $PROFILE_SCRIPT"

    # Check if default rules file exists - warn if not
    if [ ! -f "$RULES_FILE" ]; then
        print_warning "Default rules file NOT FOUND: $RULES_FILE"
        print_warning "Create this file manually!"
    else
        print_info "Default rules file exists: $RULES_FILE"
    fi

    print_success "Installed ccc v$CCC_VERSION system-wide for all users"
    print_info "Users need to log out/in or run 'source $PROFILE_SCRIPT' to use 'ccc'"
}

install_all() {
    print_info "Installing to both user and system locations..."
    install_user
    echo ""
    install_system
}

# Main
case "${1:-}" in
    --user)
        install_user
        ;;
    --global|--system)
        install_system
        ;;
    --all)
        install_all
        ;;
    --help|-h)
        show_usage
        exit 0
        ;;
    --version|-v)
        echo "ccc install script v$CCC_VERSION"
        exit 0
        ;;
    "")
        echo "Choose installation type:"
        echo "  1) User only (current user, no sudo required)"
        echo "  2) System-wide (all users, requires sudo)"
        echo "  3) Both locations"
        echo ""
        read -r -p "Enter choice [1-3]: " choice || { print_error "No input received"; exit 1; }
        case "$choice" in
            1) install_user ;;
            2) install_system ;;
            3) install_all ;;
            *) print_error "Invalid choice"; exit 1 ;;
        esac
        ;;
    *)
        print_error "Unknown option: $1"
        show_usage
        exit 1
        ;;
esac

print_success "Installation complete!"
echo ""
echo "Usage:"
echo "  ccc                    # Run continuous-claude with rules files"
echo "  ccc \"your prompt\"      # Run with a specific prompt"
echo ""
echo "Rules files:"
echo "  Default rules: Create manually (see WARNING above if missing)"
echo "  Project rules: Create 'continuous-claude-projectrules.md' in your project directory"
