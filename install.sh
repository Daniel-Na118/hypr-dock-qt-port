#!/bin/bash
# hypr-dock installation script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Determine install prefix - prefer /usr/local/bin if running with sudo, otherwise ~/.local/bin
if [ "$EUID" -eq 0 ]; then
    INSTALL_PREFIX="${1:-/usr/local/bin}"
else
    INSTALL_PREFIX="${1:-$HOME/.local/bin}"
fi

CONFIG_DIR="$HOME/.config/hypr-dock"
LOCAL_DIR="$HOME/.local/share/hypr-dock"

echo "Installing hypr-dock to $INSTALL_PREFIX..."

# Create config directory
mkdir -p "$CONFIG_DIR"
mkdir -p "$LOCAL_DIR"

# Copy default configuration
cp "$SCRIPT_DIR/configs/hypr-dock.conf" "$CONFIG_DIR/hypr-dock.conf" || true

# Create pinned apps file
touch "$LOCAL_DIR/pinned"

# Create symlink or copy shell files
if ! command -v quickshell &> /dev/null; then
    echo "Warning: quickshell not found in PATH"
    echo "Please install quickshell to run hypr-dock"
    exit 1
fi

# Create launcher script
cat > "$INSTALL_PREFIX/hypr-dock" << EOF
#!/bin/bash
PROJECT_DIR="$SCRIPT_DIR"
exec quickshell "\$PROJECT_DIR/shell.qml" "\$@"
EOF

chmod +x "$INSTALL_PREFIX/hypr-dock"

# Check if install prefix is in PATH
if [[ ":$PATH:" == *":$INSTALL_PREFIX:"* ]]; then
    echo ""
    echo "Installation complete!"
    echo "Run with: hypr-dock"
else
    echo ""
    echo "Installation complete!"
    echo ""
    echo "⚠️  WARNING: $INSTALL_PREFIX is not in your PATH"
    echo ""
    echo "Add this to your shell config (~/.bashrc, ~/.zshrc, etc):"
    echo "  export PATH=\"\$PATH:$INSTALL_PREFIX\""
    echo ""
    echo "Or run directly:"
    echo "  $INSTALL_PREFIX/hypr-dock"
fi
