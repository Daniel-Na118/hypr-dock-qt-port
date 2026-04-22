# hypr-dock-qt2

A 1:1 port of hypr-dock from Go/GTK to QML/QuickShell

## Structure

```
hypr-dock-qt2/
├── cmd/hypr-dock/
│   └── MainWindow.qml          - Main window setup
├── internal/
│   ├── app/
│   │   └── App.qml             - App UI builder (BuildApp)
│   ├── item/
│   │   └── Item.qml            - Individual dock item
│   ├── itemsctl/
│   │   └── ItemsList.qml       - Items container management
│   ├── hypr/
│   │   ├── hyprEvents/
│   │   │   └── HyprEvents.qml  - Event listeners
│   │   └── hyprOpt/
│   │       └── HyprOpt.qml     - Hyprland options
│   ├── settings/
│   │   └── Settings.qml        - Configuration management
│   ├── state/
│   │   └── State.qml           - Runtime state
│   ├── desktop/
│   │   └── Desktop.qml         - Desktop file handling
│   ├── btnctl/
│   │   └── ButtonControl.qml   - Button control dispatch
│   ├── defaultControl/
│   │   └── DefaultControl.qml  - Click handlers
│   ├── layering/
│   │   └── Layering.qml        - Wayland layer shell
│   └── pvctl/
│       └── PVControl.qml       - Window preview control
├── pkg/
│   ├── ipc/
│   │   └── IPC.qml             - Hyprland communication
│   ├── ini/
│   │   └── INIManager.qml      - INI file parsing
│   └── wl/
│       └── Wayland.qml         - Wayland protocol integration
├── configs/                     - Configuration files
├── scripts/                     - Shell scripts
└── shell.qml                    - Main entry point
```

## Port Mapping

### Core Modules (1:1 correspondence)

| Go Module | QML/JavaScript Equivalent |
|-----------|---------------------------|
| cmd/hypr-dock/main.go | shell.qml + cmd/hypr-dock/MainWindow.qml |
| internal/state | internal/state/State.qml |
| internal/settings | internal/settings/Settings.qml |
| internal/app | internal/app/App.qml |
| internal/item | internal/item/Item.qml |
| internal/itemsctl | internal/itemsctl/ItemsList.qml |
| internal/hypr/hyprEvents | internal/hypr/hyprEvents/HyprEvents.qml |
| internal/hypr/hyprOpt | internal/hypr/hyprOpt/HyprOpt.qml |
| internal/desktop | internal/desktop/Desktop.qml |
| internal/btnctl | internal/btnctl/ButtonControl.qml |
| internal/defaultControl | internal/defaultControl/DefaultControl.qml |
| internal/layering | internal/layering/Layering.qml |
| internal/pvctl | internal/pvctl/PVControl.qml |
| pkg/ipc | pkg/ipc/IPC.qml |
| pkg/ini | pkg/ini/INIManager.qml |
| pkg/wl | pkg/wl/Wayland.qml |

## Key Features Ported

1. **Single Instance Lock** - Prevents multiple instances
2. **Configuration Management** - INI file parsing and settings
3. **Desktop File Handling** - .desktop file discovery and parsing
4. **IPC Communication** - Hyprland socket communication
5. **Event Listening** - Hyprland event stream processing
6. **Window Management** - Window tracking and focus
7. **UI Layout** - Dock positioning and layout
8. **Window Preview** - Preview on hover (placeholder)
9. **Context Menus** - Window and app context menus
10. **Pinned Apps** - Support for pinning applications

## Dependencies

- QuickShell
- Qt 6.0+
- Hyprland

## Running

```bash
quickshell shell.qml
```

## Development Notes

- All functionality is maintained from the original Go implementation
- No additional features have been added
- Same folder structure is preserved for maintainability
- JavaScript/QML used instead of Go for UI logic
- Unix socket communication retained for Hyprland IPC
