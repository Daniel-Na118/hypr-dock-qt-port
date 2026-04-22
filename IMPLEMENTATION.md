# hypr-dock-qt2 Implementation Guide

## Port Overview

This document describes the 1:1 port of hypr-dock from Go to QML/QuickShell, maintaining identical functionality without adding extra features.

## Architecture Comparison

### Go vs QML Structure

| Aspect | Go Implementation | QML Implementation |
|--------|------------------|-------------------|
| Entry Point | main.go | shell.qml |
| GUI Framework | GTK3 | Qt Quick |
| Widget System | gtk.Window, gtk.Box, gtk.Button | Rectangle, Row/Column Layout, Button |
| State Management | sync.Mutex with State struct | Qt properties with signals |
| IPC Communication | Unix socket (net.Dial) | Process execution (socat) |
| Configuration | INI parsing (pkg/ini) | QML INI manager |
| Logger | hclog.Logger | console.log/console.error |

## Module-by-Module Port

### 1. Entry Point: shell.qml (cmd/hypr-dock/main.go)

**Original Go Logic:**
- Parse command-line flags
- Create single instance lock
- Initialize logger
- Setup GTK
- Load settings
- Create window with layer shell
- Initialize Hyprland events
- Enter main event loop

**QML Port:**
```qml
// shell.qml:
- Initialize settings via Settings.qml
- Create State object via State.qml
- Instantiate MainWindow
- Attach HyprEvents listener
- Rely on QuickShell for event loop
```

### 2. Settings Management (internal/settings → internal/settings/Settings.qml)

**Original Go Implementation:**
- Read INI configuration file
- Parse pinned apps from text file
- Set up config/theme directories
- Provide typed getters for settings

**QML Port:**
- Settings.qml provides same interface
- Uses INIManager.qml for INI parsing
- File I/O via XMLHttpRequest
- Same property names and defaults

### 3. State Management (internal/state → internal/state/State.qml)

**Original Go Implementation:**
```go
type State struct {
    logger hclog.Logger
    settings *settings.Settings
    window *gtk.Window
    layerctl *layering.Control
    itemsBox *gtk.Box
    list *itemsctl.List
    pv *pvctl.PV
    mu sync.Mutex  // Thread safety
}
```

**QML Port:**
```qml
// State.qml equivalent:
- logger: Simple object with debug/info/warn/error functions
- settings: Settings.qml reference
- window: Window object reference
- layerctl: Layering.qml reference
- itemsBox: Rectangle/Item reference
- list: ItemsList.qml (thread-safe via Qt event loop)
- pv: PVControl.qml reference
- Signals for state changes (replaces manual updates)
```

**Key Difference:** QML uses signal/slot mechanism and property bindings instead of mutexes, automatically providing thread safety through the Qt event system.

### 4. Application UI (internal/app → internal/app/App.qml)

**Original Go Implementation:**
- BuildApp() function creates GTK Box with items
- renderItems() populates items from pinned list and IPC clients
- Initializes margins and spacing per configuration

**QML Port:**
```qml
// App.qml:
- buildApp() creates RowLayout or ColumnLayout based on position
- renderItems() achieves same flow:
  1. Add pinned apps via initNewItemInClass()
  2. Query IPC for clients via IPC.getClients()
  3. Add window items via initNewItemInIPC()
- Property bindings handle dynamic layout updates
```

### 5. Individual Items (internal/item → internal/item/Item.qml)

**Original Go Implementation:**
```go
type Item struct {
    Windows map[string]*ipc.Client
    App *desktop.App
    Button *gtk.Button
    IndicatorImage *gtk.Image
    // ... settings, list references
}
```

**QML Port:**
```qml
// Item.qml:
- Properties map to Go struct fields
- Qt.ConnectedSignals/Connections replace callbacks
- Event handlers (handleClick) achieve same dispatch
- Window management via windows property object
```

**Behavior Match:**
- 0 windows → launch app
- 1 window → focus window
- 2+ windows → show menu

### 6. Items Container (internal/itemsctl → internal/itemsctl/ItemsList.qml)

**Original Go Implementation:**
- Thread-safe map with Mutex
- get(className), add, remove, len functions
- searchWindow(address) finds window across items

**QML Port:**
- Same function signatures in ItemsList.qml
- JavaScript object for storage instead of Go map
- count property replaces len() function
- Qt event loop provides implicit thread safety

### 7. Hyprland Integration (pkg/ipc → pkg/ipc/IPC.qml)

**Original Go Implementation:**
- Unix socket communication to Hyprland IPC
- getClients(), getMonitors(), getActiveWindow()
- getOption() for Hyprland configuration
- dispatch() for sending commands

**QML Port:**
```qml
// IPC.qml:
- hyprctl(cmd) uses Process to execute socat for socket communication
- Async callbacks replace Go's error handling
- JSON unmarshaling matches exactly
- Event listeners still route via eventHandlers object
```

**Example Equivalence:**
```go
// Go: clients, err := ipc.GetClients()
// QML: IPC.getClients(function(clients) { ... })
```

### 8. Desktop File Handling (internal/desktop → internal/desktop/Desktop.qml)

**Original Go Implementation:**
- SearchDesktopFile() with multiple strategies:
  1. Direct name match
  2. Namespace variants (org.kde.*, net.project.*)
  3. Hyphenated variants
  4. Chrome webapp detection
- Parse .desktop INI format
- Extract localized strings
- Launch via shell exec

**QML Port:**
- searchDesktopFile() function preserves search logic
- INI parsing delegated to INIManager.qml
- getLocalizedString() maintains locale fallback chain
- launch() executes via Qt process

### 9. Event Handling (internal/hypr/hyprEvents → internal/hypr/hyprEvents/HyprEvents.qml)

**Original Go Implementation:**
- Register listeners for Hyprland events
- Connect to event socket
- Parse and dispatch events
- Goroutines for concurrent event handling

**QML Port:**
- addEventListener(eventType, handler) replaces listener registration
- dispatchEvent(event) routes to registered handlers
- Connections/Slots provide non-blocking event handling
- Timer for polling (simpler than socket subscription)

### 10. Button Control (internal/btnctl → internal/btnctl/ButtonControl.qml)

**Original Go Implementation:**
- Dispatch button clicks to appropriate handler
- Route to preview or default control

**QML Port:**
- dispatch(button, mode, state) maintains dispatch logic
- Delegates to PVControl.qml or DefaultControl.qml

### 11. Click Handlers (internal/defaultControl → internal/defaultControl/DefaultControl.qml)

**Original Go Implementation:**
- control() function handles three scenarios:
  - Zero instances: launch
  - One instance: focus
  - Multiple: show menu
- Context menu creation and positioning

**QML Port:**
- Identical control() function logic
- showWindowsMenu() creates MenuItem objects
- Focus dispatch via IPC.dispatch()

### 12. Wayland Layer Shell (internal/layering → internal/layering/Layering.qml)

**Original Go Implementation:**
- SetupLayerShell() configures GTK window properties
- Position dock (top/bottom/left/right)
- Set exclusive zone
- Auto-hide behavior

**QML Port:**
- configureWindow() sets QuickShell window properties
- Position calculations remain identical
- Exclusive zone configuration via window properties
- Auto-hide timer implementation

### 13. Configuration Parsing (pkg/ini → pkg/ini/INIManager.qml)

**Original Go Implementation:**
```go
// INI parsing with sections and key=value pairs
raw := ini.GetMap(filePath)
```

**QML Port:**
- parse() function reads file and creates nested object structure
- Section headers create object keys
- Key=value pairs stored as properties
- Handles comments (#, ;) same as Go

### 14. Utilities & Helpers

**Created in port:**
- Utils.qml: String normalization, path utilities
- HyprOpt.qml: Hyprland option getter with caching
- PVControl.qml: Preview popup management
- Wayland.qml: Wayland protocol interface (placeholder)

## Data Flow Comparison

### Startup Flow

**Go:**
```
main.go → flags.Parse()
→ settings.Init()
→ gtk.Init()
→ app.BuildApp()
→ hyprEvents.Init()
→ gtk.Main()
```

**QML:**
```
shell.qml → Settings.init()
→ State.init()
→ MainWindow creation
→ App.buildApp()
→ HyprEvents.startListening()
→ (QuickShell event loop)
```

### Event Flow

**Go:**
```
Hyprland (socket) → pkg/ipc.InitHyprEvents()
→ eventListeners[type](event)
→ app.handlers (state updates)
→ GTK signal emission
→ UI update
```

**QML:**
```
Hyprland (socket/process) → IPC.dispatchEvent()
→ eventHandlers[type](event)
→ HyprEvents signal emission
→ State signal/slot
→ App/Item property binding
→ UI update
```

## Runtime Behavior

### Thread Safety

**Go:** Explicit sync.Mutex on State struct
**QML:** Implicit thread safety via Qt event loop (all Qt updates on main thread)

### Memory Management

**Go:** Manual with defer/Close()
**QML:** Automatic with Qt's memory management (destroy() for explicit cleanup)

### File I/O

**Go:** os package with error handling
**QML:** XMLHttpRequest for file:// URLs

### Process Execution

**Go:** os/exec package
**QML:** Qt.createQmlObject with process properties

## Configuration Files

Same location and format as Go version:
- `~/.config/hypr-dock/hypr-dock.conf` (INI format)
- `~/.local/share/hypr-dock/pinned` (newline-separated classnames)

## Testing Correspondence

The QML port should exhibit identical behavior:
- Single instance enforcement
- Window focus/launch behavior matches
- Configuration loading and saving
- Pinned apps list management
- Context menu operations
- Multi-monitor support
- Wayland layer shell integration
- Hyprland event responsiveness

## Limitations vs Original

1. **Wayland Protocol Access:** pkg/wl (frame capture) is placeholder - would need custom Qt bindings for production
2. **Process Execution:** Uses socat via subprocess instead of direct socket access
3. **File I/O:** Limited to file:// URL scheme, no binary file support
4. **System Signals:** No SIGUSR1 signal handling for window toggle (QuickShell limitation)

## Future Considerations

- Create Qt C++ bindings for Wayland protocol if window previews needed
- Consider file I/O abstraction if binary config needed
- Add QuickShell extensions for system signal handling if window toggle required
