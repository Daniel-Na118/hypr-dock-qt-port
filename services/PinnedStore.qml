pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string filePath: (Quickshell.env("HOME") || "") + "/.local/share/hypr-dock/pinned"
    property var list: []

    signal changed()

    function isPinned(cls) {
        return list.indexOf(cls) !== -1;
    }

    function add(cls) {
        if (!cls || isPinned(cls)) return;
        const next = list.slice();
        next.push(cls);
        list = next;
        view.setText(list.join("\n") + "\n");
        changed();
    }

    function remove(cls) {
        if (!cls) return;
        const next = list.filter(c => c !== cls);
        if (next.length === list.length) return;
        list = next;
        view.setText(list.join("\n") + "\n");
        changed();
    }

    function toggle(cls) {
        if (isPinned(cls)) remove(cls); else add(cls);
    }

    FileView {
        id: view
        path: root.filePath
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            const lines = text().split(/\r?\n/).map(s => s.trim()).filter(s => s.length > 0);
            root.list = lines;
            root.changed();
        }
        onLoadFailed: {
            root.list = [];
            root.changed();
        }
    }
}
