pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland
import "."

Singleton {
    id: root

    // Each entry: {
    //   key:           string  // class (or normalized title fallback)
    //   pinned:        bool
    //   windows:       [{ address, title, workspace }]
    //   desktopEntry:  DesktopEntry | null
    //   icon:          string  // freedesktop icon name (or class fallback)
    //   name:          string  // display name
    // }
    property var items: []

    // Pull dependencies as bindable expressions.
    readonly property var _toplevels: Hyprland.toplevels ? Hyprland.toplevels.values : []
    readonly property var _pinned: PinnedStore.list

    onItemsChanged: {} // keep property reactive
    on_ToplevelsChanged: _rebuild()
    on_PinnedChanged: _rebuild()
    Component.onCompleted: _rebuild()

    function _normalize(s) {
        return (s || "").toString().toLowerCase().replace(/\s+/g, "_");
    }

    function _resolveDesktopEntry(cls) {
        if (!cls) return null;
        const direct = DesktopEntries.byId(cls);
        if (direct) return direct;
        const lower = DesktopEntries.byId(cls.toLowerCase());
        if (lower) return lower;
        // Fallback scan: id endsWith "." + cls (e.g. org.kde.dolphin for class "dolphin")
        const apps = DesktopEntries.applications ? DesktopEntries.applications.values : [];
        const needle = cls.toLowerCase();
        for (let i = 0; i < apps.length; ++i) {
            const id = (apps[i].id || "").toLowerCase();
            if (id === needle) return apps[i];
            if (id.endsWith("." + needle)) return apps[i];
        }
        return null;
    }

    function _rebuild() {
        const toplevels = root._toplevels || [];
        const pinned = root._pinned || [];

        // Group windows by class (or normalized title fallback).
        const groups = {};
        const order = [];
        for (let i = 0; i < toplevels.length; ++i) {
            const t = toplevels[i];
            const cls = t.class && t.class.length > 0
                ? t.class
                : root._normalize(t.title);
            if (!groups[cls]) {
                groups[cls] = [];
                order.push(cls);
            }
            groups[cls].push({
                address: t.address,
                title: t.title,
                workspace: t.workspace ? t.workspace.id : -1
            });
        }

        const out = [];
        const seen = {};

        // 1. Pinned items first, in config order.
        for (let i = 0; i < pinned.length; ++i) {
            const cls = pinned[i];
            const entry = root._resolveDesktopEntry(cls);
            const wins = groups[cls] || [];
            out.push({
                key: cls,
                pinned: true,
                windows: wins,
                desktopEntry: entry,
                icon: (entry && entry.icon) ? entry.icon : cls,
                name: (entry && entry.name) ? entry.name : cls
            });
            seen[cls] = true;
        }

        // 2. Unpinned-but-running, in window-creation order.
        for (let i = 0; i < order.length; ++i) {
            const cls = order[i];
            if (seen[cls]) continue;
            const entry = root._resolveDesktopEntry(cls);
            out.push({
                key: cls,
                pinned: false,
                windows: groups[cls],
                desktopEntry: entry,
                icon: (entry && entry.icon) ? entry.icon : cls,
                name: (entry && entry.name) ? entry.name : cls
            });
        }

        items = out;
    }
}
