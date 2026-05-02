pragma Singleton
import QtQuick
import Quickshell
import "."

Singleton {
    id: root

    function focusToplevel(toplevel) {
        if (toplevel) toplevel.activate();
    }

    function closeToplevel(toplevel) {
        if (toplevel && toplevel.close) toplevel.close();
    }

    function launch(entry) {
        if (entry) entry.execute();
    }

    // Combined left-click behavior matching the original:
    //   0 windows  -> launch
    //   1 window   -> focus that window
    //   2+ windows -> caller should open a window-list popup (phase 3);
    //                 phase 2 cycles through them.
    function activate(item) {
        if (!item) return;
        const tops = item.toplevels || [];
        if (tops.length === 0) {
            launch(item.desktopEntry);
            return;
        }
        if (tops.length === 1) {
            focusToplevel(tops[0]);
            return;
        }
        let idx = 0;
        for (let i = 0; i < tops.length; ++i) {
            if (tops[i].activated) { idx = i; break; }
        }
        focusToplevel(tops[(idx + 1) % tops.length]);
    }
}
