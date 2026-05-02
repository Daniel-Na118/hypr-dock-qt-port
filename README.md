# hypr-dock-qt

A Quickshell port of [hypr-dock](https://github.com/lotos-linux/hypr-dock) (originally Go + GTK3).

The port keeps the original look and behavior, but is built with Quickshell's
native Wayland and Hyprland integrations rather than re-implementing them. It is shorter, more declarative, and uses APIs that work across wlroots
compositors — but a few of the original's options aren't yet implemented.
See [Differences from the original](#differences-from-the-original) below.

## Run

```sh
qs -p /path/to/hypr-dock-qt-port
```

Or, if you symlink the directory into `~/.config/quickshell/hypr-dock-qt`:

```sh
qs -c hypr-dock-qt
```

To launch with Hyprland:

```text
exec-once = qs -c hypr-dock-qt
```

Optional, for the same blur look the original ships:

```text
layerrule = blur true,match:namespace hypr-dock
layerrule = ignore_alpha 0,match:namespace hypr-dock
```

## Dependencies

- Quickshell (current — uses `Quickshell.Wayland.ToplevelManager`,
  `Quickshell.Wayland.ScreencopyView`, `Quickshell.Hyprland.HyprlandFocusGrab`,
  `Quickshell.DesktopEntries.heuristicLookup`)
- Hyprland (other wlroots compositors will mostly work; the focus grab is
  Hyprland-specific)

## Features

- One dock per output, anchored bottom, with Hyprland's exclusive-zone reserved.
- Pinned apps (in config order) followed by unpinned-but-running apps.
- Per-app grouping: every window of an app collapses onto one icon with a
  running-count indicator (`0/1/2/3+.svg` from the active theme).
- Active-window highlight on the focused app's icon.
- Left-click:
  - 0 windows → launch via the resolved `.desktop` entry
  - 1 window → focus it
  - 2+ windows → cycle through them
- Right-click → context menu, in the same order as the original:
  1. Open windows (each row focuses that window)
  2. `.desktop` `Actions`
  3. Launch / `New Window - {AppName}` (hidden when `SingleMainWindow=true`
     and a window already exists)
  4. `Pin` / `Unpin`
  5. `Close` (only when exactly one window is open)
- Hover → live `ScreencopyView` preview popup of every window of the app, with
  a per-thumbnail × close button. Click a thumbnail to activate that window.
  500 ms show / 350 ms hide delay.
- Mutual exclusion: opening a menu hides the preview and any other open menu;
  showing a preview closes any open menu.
- Click-outside dismissal of the menu via `HyprlandFocusGrab`.

## Configuration

### Main config — `~/.config/hypr-dock/hypr-dock.conf`

INI format, same keys as the original, all optional

```ini
[General]
CurrentTheme   = lotos    ; theme directory under ./theme/
IconSize       = 23       ; icon size in px
Layer          = top      ; background | bottom | top | overlay (currently always top)
Exclusive      = true     ; reserve space so tiling doesn't overlap the dock
SmartView      = false    ; (not yet implemented in this port)
Position       = bottom   ; top | bottom | left | right (currently always bottom)
AutoHideDelay  = 400      ; (not yet implemented in this port)
SystemGapUsed  = true     ; (not yet implemented in this port — Margin is always used)
Margin         = 8        ; px from the screen edge
ContextPos     = 5
```

If the user file is missing, the bundled `configs/hypr-dock.conf` is used as a
fallback so the dock still starts

### Theme — `theme/{CurrentTheme}/theme.conf`

```ini
[Theme]
Spacing = 5    ; px between dock items
```

The theme directory also contains `point/0.svg`, `point/1.svg`, `point/2.svg`,
`point/3.svg` — the running-count indicators. The shipped `lotos` theme is
copied verbatim from the original

### Pinned apps — `~/.local/share/hypr-dock/pinned`

One app id per line:

```text
firefox
org.kde.dolphin
code-oss
org.telegram.desktop
kitty
```

You can pin/unpin by right-clicking the dock icon — the file is rewritten on
each toggle and watched for external edits

## Project layout

```
hypr-dock-qt-port/
├── shell.qml                       # ShellRoot, one Dock per screen
├── modules/
│   ├── Dock.qml                    # PanelWindow, layout, popup arbitration, focus grab
│   ├── DockItem.qml                # icon + indicator, click handlers, builds the menu
│   ├── Indicator.qml               # selects 0/1/2/3.svg by running count
│   ├── DockItemMenu.qml            # right-click PopupWindow rendering the row model
│   └── WindowPreviewPopup.qml      # hover PopupWindow with ScreencopyView per window
├── services/                       # singletons (qmldir registers them)
│   ├── Settings.qml                # FileView + INI parser, user → bundled fallback
│   ├── PinnedStore.qml             # FileView pinned-list, watched + rewritten on toggle
│   ├── DockModel.qml               # merges ToplevelManager + PinnedStore + DesktopEntries
│   ├── HyprActions.qml             # focus / close / launch wrappers
│   └── qmldir
├── configs/hypr-dock.conf          # bundled defaults
└── theme/lotos/                    # bundled theme assets
```

## Mapping to the original Go modules

The port leans on Quickshell APIs instead of reimplementing the original
helpers from scratch.

| Original Go module                        | Replacement                                        |
|-------------------------------------------|----------------------------------------------------|
| `internal/layering`                       | `Quickshell.Wayland.PanelWindow` + `WlrLayershell` |
| `internal/hypr/hyprEvents` (socket2)      | `Quickshell.Wayland.ToplevelManager` (reactive)    |
| `internal/desktop` (.desktop discovery)   | `Quickshell.DesktopEntries.heuristicLookup`        |
| Icon resolution (GTK theme)               | `Quickshell.iconPath` + `Quickshell.Widgets.IconImage` |
| `internal/hysc` (live screencopy)         | `Quickshell.Wayland.ScreencopyView` (`live: true`) |
| `internal/pkg/conf` (INI loader)          | `Quickshell.Io.FileView` + small JS INI parser     |
| `internal/pkg/pinned`                     | `FileView` (`watchChanges: true`)                  |
| `internal/pkg/popup`                      | `Quickshell.PopupWindow`                           |
| `singleinstance` lock                     | Quickshell shells are inherently single-instance   |
| Outside-click menu dismissal              | `Quickshell.Hyprland.HyprlandFocusGrab`            |
| `internal/app`, `item`, `itemsctl`        | `services/DockModel.qml` + `modules/DockItem.qml`  |
| `internal/btnctl`, `defaultControl`       | `MouseArea` handlers in `DockItem.qml`             |
| `internal/pvctl`, `pvwidget`              | `modules/WindowPreviewPopup.qml`                   |

## Differences from the original

Tried to create a 1-1 port from the original, but changed the structure to utilize Hyprland protocols

- One declarative reactive model (`DockModel`) instead of imperative
  add/remove plumbing — opening or closing a window updates the dock without
  any explicit event handler
- Live `ScreencopyView` previews are always on; the original gates this behind
  `Mode = live` and labels it experimental
- Cross-compositor toplevel grouping via the wlr foreign-toplevel protocol,
  rather than parsing Hyprland's clients JSON
- Click-outside menu dismissal via `HyprlandFocusGrab`

**Not implemented**

- `SmartView` autohide and the 1px detection zone.
- `Position = top | left | right` (currently always bottom — orientation
  rotation is straightforward to add later).
- `Layer` switching (always `top`).
- `SystemGapUsed = true` — sync with Hyprland's `general:gaps_out`.
- Theme `style.css` overrides (the bundled CSS isn't honored — visual constants
  are hardcoded to the `lotos` defaults).
- `ContextPos` (popup gap to item is fixed at 8 px).
- Static-mode preview (`Mode = static`); only live thumbnails are rendered.
- Multi-monitor active-monitor logic — every screen gets its own dock.


## Credits

Original: <https://github.com/lotos-linux/hypr-dock>

Honestly made this project for my own use, you can use or change it for your own use if you want