pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Wayland
import "."

Singleton {
    id: root

    // Each entry: {
    //   key:           string  // appId (or pinned class) lowercased
    //   pinned:        bool
    //   toplevels:     [ToplevelManager.Toplevel]   // live refs, expose .activate(), .activated, .title
    //   desktopEntry:  DesktopEntry | null
    //   icon:          string  // freedesktop icon name or appId fallback
    //   name:          string  // display name
    // }
    property var items: []

    readonly property var _toplevels: ToplevelManager.toplevels ? ToplevelManager.toplevels.values : []
    readonly property var _pinned: PinnedStore.list

    on_ToplevelsChanged: _rebuild()
    on_PinnedChanged: _rebuild()
    Component.onCompleted: _rebuild()

    Connections {
        target: DesktopEntries
        function onApplicationsChanged() { root._rebuild(); }
    }

    function _entryFor(appId) {
        if (!appId) return null;
        return DesktopEntries.heuristicLookup(appId) || null;
    }

    function _rebuild() {
        const tops = root._toplevels || [];
        const pinned = root._pinned || [];

        const groups = new Map();
        const order = [];

        // Seed pinned classes first (so pinned-but-not-running entries appear).
        for (const cls of pinned) {
            const key = (cls || "").toLowerCase();
            if (!key || groups.has(key)) continue;
            groups.set(key, { displayId: cls, pinned: true, toplevels: [] });
            order.push(key);
        }

        // Group running toplevels by appId (lowercased).
        for (const t of tops) {
            const appId = t.appId || "";
            if (!appId) continue;
            const key = appId.toLowerCase();
            if (!groups.has(key)) {
                groups.set(key, { displayId: appId, pinned: false, toplevels: [] });
                order.push(key);
            }
            groups.get(key).toplevels.push(t);
        }

        const out = [];
        for (const key of order) {
            const g = groups.get(key);
            const entry = root._entryFor(g.displayId);
            out.push({
                key: key,
                appId: g.displayId,
                pinned: g.pinned,
                toplevels: g.toplevels,
                desktopEntry: entry,
                icon: (entry && entry.icon) ? entry.icon : g.displayId,
                name: (entry && entry.name) ? entry.name : g.displayId
            });
        }

        items = out;
    }
}
