#!/bin/bash
# install.sh - Install ccc (continuous-claude wrapper)
# Source: https://github.com/BPMspaceUG/bpm-ContinousClaudeCoding

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

show_usage() {
    echo "Usage: $0 [--user | --system]"
    echo ""
    echo "Options:"
    echo "  --user    Install for current user only (~/.bashrc)"
    echo "  --system  Install system-wide for all users (/etc/profile.d/) - requires sudo"
    echo ""
    echo "If no option is provided, you will be prompted to choose."
}

install_user() {
    print_info "Installing for current user..."

    # Copy function to user's bashrc
    BASHRC="$HOME/.bashrc"
    RULES_FILE="$HOME/.continuous-claude-defaultrules.md"

    # Remove old installation if exists
    if grep -q "# ccc - continuous-claude wrapper" "$BASHRC" 2>/dev/null; then
        print_info "Removing previous installation..."
        sed -i '/# ccc - continuous-claude wrapper/,/^}$/d' "$BASHRC"
    fi

    # Add marker and function
    echo "" >> "$BASHRC"
    echo "# ccc - continuous-claude wrapper (installed by bpm-ContinousClaudeCoding)" >> "$BASHRC"
    cat "$SCRIPT_DIR/src/continuous-claude.sh" >> "$BASHRC"

    # Check if default rules file exists - warn if not
    if [ ! -f "$RULES_FILE" ]; then
        print_warning "Default rules file NOT FOUND: $RULES_FILE"
        print_warning "Create this file manually or copy the template:"
        echo "         cp $SCRIPT_DIR/templates/continuous-claude-defaultrules.md $RULES_FILE"
    else
        print_info "Default rules file exists: $RULES_FILE"
    fi

    print_success "Installed for user: $USER"
    print_info "Run 'source ~/.bashrc' or open a new terminal to use 'ccc'"
}

install_system() {
    print_info "Installing system-wide (requires sudo)..."

    # Check for sudo
    if ! sudo -v 2>/dev/null; then
        print_error "sudo access required for system-wide installation"
        exit 1
    fi

    PROFILE_SCRIPT="/etc/profile.d/continuous-claude.sh"
    RULES_FILE="/etc/continuous-claude-defaultrules.md"

    # Copy function to profile.d
    sudo cp "$SCRIPT_DIR/src/continuous-claude.sh" "$PROFILE_SCRIPT"
    sudo chmod 644 "$PROFILE_SCRIPT"
    print_info "Installed shell function: $PROFILE_SCRIPT"

    # Check if default rules file exists - warn if not
    if [ ! -f "$RULES_FILE" ]; then
        print_warning "Default rules file NOT FOUND: $RULES_FILE"
        print_warning "Create this file manually or copy the template:"
        echo "         sudo cp $SCRIPT_DIR/templates/continuous-claude-defaultrules.md $RULES_FILE"
    else
        print_info "Default rules file exists: $RULES_FILE"
    fi

    print_success "Installed system-wide for all users"
    print_info "Users need to log out/in or run 'source $PROFILE_SCRIPT' to use 'ccc'"
}

# Main
case "${1:-}" in
    --user)
        install_user
        ;;
    --system)
        install_system
        ;;
    --help|-h)
        show_usage
        exit 0
        ;;
    "")
        echo "Choose installation type:"
        echo "  1) User only (current user, no sudo required)"
        echo "  2) System-wide (all users, requires sudo)"
        echo ""
        read -p "Enter choice [1/2]: " choice
        case "$choice" in
            1) install_user ;;
            2) install_system ;;
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
echo ""
echo "Templates available in: $SCRIPT_DIR/templates/"
