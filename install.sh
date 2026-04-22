#!/bin/bash
# hypr-dock-qt2 installation script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_PREFIX="${1:~/.local/bin}"
CONFIG_DIR="$HOME/.config/hypr-dock"
LOCAL_DIR="$HOME/.local/share/hypr-dock"

echo "Installing hypr-dock-qt2..."

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
    echo "Please install quickshell to run hypr-dock-qt2"
    exit 1
fi

# Create launcher script
cat > "$INSTALL_PREFIX/hypr-dock-qt2" << 'EOF'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec quickshell "$SCRIPT_DIR/shell.qml" "$@"
EOF

chmod +x "$INSTALL_PREFIX/hypr-dock-qt2"

echo "Installation complete!"
echo "Run with: hypr-dock-qt2"
