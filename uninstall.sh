#!/bin/bash
# hypr-dock-qt2 uninstallation script

set -e

INSTALL_PREFIX="${1:~/.local/bin}"
CONFIG_DIR="$HOME/.config/hypr-dock"
LOCAL_DIR="$HOME/.local/share/hypr-dock"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}hypr-dock Uninstaller${NC}"
echo "=================================="

# Check if installed
if [ ! -f "$INSTALL_PREFIX/hypr-dock" ]; then
    echo -e "${RED}✗ hypr-dock not found in $INSTALL_PREFIX${NC}"
    exit 1
fi

# Remove launcher script
echo "Removing launcher script..."
rm -f "$INSTALL_PREFIX/hypr-dock"
echo -e "${GREEN}✓ Launcher removed${NC}"

# Ask about configuration
echo ""
echo "Do you want to remove configuration files?"
echo "  Config: $CONFIG_DIR"
echo "  Data:   $LOCAL_DIR"
read -p "Remove configuration and data? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Removing configuration..."
    rm -rf "$CONFIG_DIR"
    echo -e "${GREEN}✓ Configuration removed${NC}"
    
    echo "Removing user data..."
    rm -rf "$LOCAL_DIR"
    echo -e "${GREEN}✓ User data removed${NC}"
else
    echo -e "${YELLOW}✓ Keeping configuration at $CONFIG_DIR${NC}"
    echo -e "${YELLOW}✓ Keeping user data at $LOCAL_DIR${NC}"
fi

echo ""
echo -e "${GREEN}Uninstall complete!${NC}"
echo "hypr-dock has been removed from $INSTALL_PREFIX"
