pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland
import "."

Singleton {
    id: root

    function focusWindow(address) {
        if (!address) return;
        Hyprland.dispatch("focuswindow address:" + address);
    }

    function closeWindow(address) {
        if (!address) return;
        Hyprland.dispatch("closewindow address:" + address);
    }

    function launch(entry) {
        if (!entry) return;
        // DesktopEntry.execute() handles Exec field substitution.
        entry.execute();
    }

    // Combined left-click behavior matching the original:
    //   0 windows  -> launch
    //   1 window   -> focus that window
    //   2+ windows -> caller should open a window-list popup (phase 3);
    //                 for now we cycle through them.
    function activate(item) {
        if (!item) return;
        const windows = item.windows || [];
        if (windows.length === 0) {
            launch(item.desktopEntry);
            return;
        }
        if (windows.length === 1) {
            focusWindow(windows[0].address);
            return;
        }
        // Phase-2 fallback: cycle. Phase 3 will replace this with a popup.
        const focused = Hyprland.focusedWorkspace
            ? (Hyprland.focusedToplevel ? Hyprland.focusedToplevel.address : null)
            : null;
        let idx = 0;
        for (let i = 0; i < windows.length; ++i) {
            if (windows[i].address === focused) { idx = i; break; }
        }
        const next = windows[(idx + 1) % windows.length];
        focusWindow(next.address);
    }
}
