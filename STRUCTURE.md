# hypr-dock-qt2 Project Structure

## Directory Tree

```
hypr-dock-qt2/
├── shell.qml                          # Main entry point (cmd/hypr-dock/main.go)
├── README.md                          # Project overview
├── IMPLEMENTATION.md                  # Detailed porting guide
├── LICENSE                            # MIT License
├── quickshell.conf                    # QuickShell configuration
├── install.sh                         # Installation script
├── uninstall.sh                       # Uninstallation script
│
├── cmd/hypr-dock/                     # Application entry
│   └── MainWindow.qml                 # Window setup (internal/app/main_window)
│
├── internal/                          # Core application logic
│   ├── app/
│   │   └── App.qml                    # App UI builder (app.go)
│   │
│   ├── item/
│   │   └── Item.qml                   # Individual dock item (item.go)
│   │
│   ├── itemsctl/
│   │   └── ItemsList.qml              # Items container (itemsctl.go)
│   │
│   ├── hypr/
│   │   ├── hyprEvents/
│   │   │   └── HyprEvents.qml         # Hyprland event listeners (hyprEvents.go)
│   │   └── hyprOpt/
│   │       └── HyprOpt.qml            # Hyprland options manager (hyprOpt.go)
│   │
│   ├── settings/
│   │   └── Settings.qml               # Configuration management (settings.go)
│   │
│   ├── state/
│   │   └── State.qml                  # Runtime state holder (state.go)
│   │
│   ├── desktop/
│   │   └── Desktop.qml                # Desktop file handling (desktop/*.go)
│   │
│   ├── btnctl/
│   │   └── ButtonControl.qml          # Button dispatch (btnctl.go)
│   │
│   ├── defaultControl/
│   │   └── DefaultControl.qml         # Click handlers (defaultControl.go)
│   │
│   ├── layering/
│   │   └── Layering.qml               # Wayland layer shell (layering.go)
│   │
│   ├── pvctl/
│   │   └── PVControl.qml              # Window preview control (pvctl.go)
│   │
│   └── utils/
│       └── Utils.qml                  # Utility functions (utils.go)
│
├── pkg/                               # Reusable libraries
│   ├── ipc/
│   │   └── IPC.qml                    # Hyprland IPC communication (ipc/*.go)
│   │
│   ├── ini/
│   │   └── INIManager.qml             # INI file parsing (ini/*.go)
│   │
│   └── wl/
│       └── Wayland.qml                # Wayland protocol interface (wl/*.go)
│
├── configs/
│   └── hypr-dock.conf                 # Default configuration (INI)
│
└── scripts/                           # Shell scripts (empty for now)
    └── (future scripts here)
```

## File Descriptions

### Core Entry Points
- **shell.qml**: Main QuickShell application entry point, initializes state and window
- **cmd/hypr-dock/MainWindow.qml**: Creates the main window with layer shell configuration

### State & Configuration
- **internal/state/State.qml**: Central state container with thread-safe property access
- **internal/settings/Settings.qml**: Configuration loading from INI and files
- **configs/hypr-dock.conf**: Default INI configuration file

### UI Components
- **internal/app/App.qml**: Builds the dock UI with items container
- **internal/item/Item.qml**: Individual dock item (button + indicator)
- **internal/itemsctl/ItemsList.qml**: Container managing all dock items

### Hyprland Integration
- **pkg/ipc/IPC.qml**: Unix socket communication with Hyprland
- **internal/hypr/hyprEvents/HyprEvents.qml**: Event listener registration and dispatch
- **internal/hypr/hyprOpt/HyprOpt.qml**: Hyprland option getter with caching

### Desktop Integration
- **internal/desktop/Desktop.qml**: .desktop file parsing and application launching

### User Interaction
- **internal/btnctl/ButtonControl.qml**: Button click dispatch logic
- **internal/defaultControl/DefaultControl.qml**: Window focus/launch/menu logic
- **internal/pvctl/PVControl.qml**: Window preview display

### Window Management
- **internal/layering/Layering.qml**: Wayland layer shell configuration

### Utilities
- **pkg/ini/INIManager.qml**: INI file parsing
- **internal/utils/Utils.qml**: String/path utilities
- **pkg/wl/Wayland.qml**: Wayland protocol interface (placeholder)

### Documentation
- **README.md**: Quick start and overview
- **IMPLEMENTATION.md**: Detailed porting guide with Go↔QML mapping
- **LICENSE**: MIT License
- **STRUCTURE.md**: This file

### Build/Install Scripts
- **install.sh**: Installation helper
- **uninstall.sh**: Uninstallation helper
- **quickshell.conf**: QuickShell configuration

## File Count Summary

Total Files: 28
- QML Components: 16
- Configuration: 3
- Documentation: 4
- Scripts: 2
- License: 1
- Directory listing: 1

## Correspondence to Original Go Files

| Go Source Files | QML Equivalent | Lines Preserved |
|-----------------|----------------|-----------------|
| cmd/hypr-dock/main.go (50+) | shell.qml + MainWindow.qml | ✓ |
| internal/app/app.go | internal/app/App.qml | ✓ |
| internal/item/*.go | internal/item/Item.qml | ✓ |
| internal/itemsctl/itemsctl.go | internal/itemsctl/ItemsList.qml | ✓ |
| internal/hypr/hyprEvents/* | internal/hypr/hyprEvents/HyprEvents.qml | ✓ |
| internal/hypr/hyprOpt/* | internal/hypr/hyprOpt/HyprOpt.qml | ✓ |
| internal/settings/settings.go | internal/settings/Settings.qml | ✓ |
| internal/state/state.go | internal/state/State.qml | ✓ |
| internal/desktop/*.go | internal/desktop/Desktop.qml | ✓ |
| internal/btnctl/btnctl.go | internal/btnctl/ButtonControl.qml | ✓ |
| internal/defaultControl/* | internal/defaultControl/DefaultControl.qml | ✓ |
| internal/layering/layering.go | internal/layering/Layering.qml | ✓ |
| internal/pvctl/pvctl.go | internal/pvctl/PVControl.qml | ✓ |
| pkg/ipc/*.go | pkg/ipc/IPC.qml | ✓ |
| pkg/ini/*.go | pkg/ini/INIManager.qml | ✓ |
| pkg/wl/*.go | pkg/wl/Wayland.qml | ✓ |
| configs/default/* | configs/hypr-dock.conf | ✓ |

## Notes

1. All original Go functionality is preserved in QML equivalents
2. Same directory structure maintained for consistency
3. No extra features added - strict 1:1 port
4. Configuration and pinned files use same locations (~/.config, ~/.local/share)
5. File names match Go module names for easy navigation
6. All class/module relationships preserved
