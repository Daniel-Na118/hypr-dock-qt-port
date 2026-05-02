import QtQuick
import Quickshell
import Quickshell.Widgets
import "../services"

Item {
    id: root

    property var item                 // entry from DockModel.items
    property var panelWindow          // PanelWindow ref (popup anchor)
    property int iconSize: 23
    property int itemPadding: 4
    property int radius: 12

    signal hoverChanged(bool entered, Item button, var entry)

    readonly property string iconName: item ? item.icon : ""
    readonly property string displayName: item ? item.name : ""
    readonly property var toplevels: item && item.toplevels ? item.toplevels : []
    readonly property int runningCount: toplevels.length
    readonly property bool isActive: {
        for (let i = 0; i < toplevels.length; ++i)
            if (toplevels[i] && toplevels[i].activated) return true;
        return false;
    }

    readonly property int indicatorWidth: Math.round(iconSize * 0.56)
    readonly property int indicatorHeight: Math.max(2, Math.round(indicatorWidth * 9 / 48))
    readonly property int indicatorGap: 1

    property int _cycleIdx: -1

    implicitWidth: iconSize + itemPadding * 2
    implicitHeight: iconSize + itemPadding * 2 + indicatorHeight + indicatorGap

    function _cycleNext() {
        if (toplevels.length === 0) return;
        let idx = -1;
        for (let i = 0; i < toplevels.length; ++i) {
            if (toplevels[i] && toplevels[i].activated) { idx = i; break; }
        }
        const start = idx >= 0 ? idx : root._cycleIdx;
        const next = (start + 1) % toplevels.length;
        root._cycleIdx = next;
        HyprActions.focusToplevel(toplevels[next]);
    }

    function _showContextMenu() {
        if (!item) return;
        const entry = item.desktopEntry;
        const rows = [];

        // 1. Windows list (each row: app icon + title -> focus that toplevel)
        for (let i = 0; i < toplevels.length; ++i) {
            const t = toplevels[i];
            rows.push({
                kind: "row",
                label: t.title || displayName,
                icon: iconName,
                onTriggered: () => HyprActions.focusToplevel(t)
            });
        }
        if (toplevels.length > 0) rows.push({ kind: "separator" });

        // 2. .desktop Actions
        if (entry && entry.actions) {
            for (let i = 0; i < entry.actions.length; ++i) {
                const a = entry.actions[i];
                rows.push({
                    kind: "row",
                    label: a.name || a.id,
                    icon: a.icon || "",
                    onTriggered: () => a.execute()
                });
            }
            if (entry.actions.length > 0) rows.push({ kind: "separator" });
        }

        // 3. Launch row.
        //    - hidden entirely if running AND singleMainWindow
        //    - "{AppName}" with no windows; "New Window - {AppName}" with windows
        if (entry) {
            const single = !!entry.singleMainWindow;
            const skipLaunch = (toplevels.length > 0) && single;
            if (!skipLaunch) {
                const baseName = entry.name || displayName;
                const launchLabel = toplevels.length === 0
                    ? baseName
                    : "New Window - " + baseName;
                rows.push({
                    kind: "row",
                    label: launchLabel,
                    icon: iconName,
                    onTriggered: () => HyprActions.launch(entry)
                });
            }
        }

        // 4. Pin / Unpin
        rows.push({
            kind: "row",
            label: item.pinned ? "Unpin" : "Pin",
            onTriggered: () => PinnedStore.toggle(item.appId || item.key)
        });

        // 5. Close (only when exactly 1 window)
        if (toplevels.length === 1) {
            rows.push({
                kind: "row",
                label: "Close",
                onTriggered: () => HyprActions.closeToplevel(toplevels[0])
            });
        }

        menu.rows = rows;
        if (panelWindow && panelWindow.requestMenuOpen) panelWindow.requestMenuOpen(menu);
        else menu.open();
    }

    Rectangle {
        id: button
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: root.iconSize + root.itemPadding * 2
        height: root.iconSize + root.itemPadding * 2
        radius: root.radius
        color: {
            if (hoverArea.containsMouse) return Qt.rgba(1, 1, 1, 0.10);
            if (root.isActive) return Qt.rgba(1, 1, 1, 0.06);
            return "transparent";
        }

        IconImage {
            anchors.centerIn: parent
            implicitSize: root.iconSize
            source: root.iconName ? Quickshell.iconPath(root.iconName, "image-missing") : ""
        }

        MouseArea {
            id: hoverArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            cursorShape: Qt.PointingHandCursor
            onEntered: root.hoverChanged(true, root, root.item)
            onExited:  root.hoverChanged(false, root, root.item)
            onClicked: mouse => {
                if (!root.item) return;
                if (mouse.button === Qt.LeftButton) {
                    if (root.runningCount === 0) {
                        HyprActions.launch(root.item.desktopEntry);
                    } else if (root.runningCount === 1) {
                        HyprActions.focusToplevel(root.toplevels[0]);
                    } else {
                        root._cycleNext();
                    }
                } else if (mouse.button === Qt.RightButton) {
                    root._showContextMenu();
                }
            }
        }

    }

    Indicator {
        anchors.top: button.bottom
        anchors.topMargin: root.indicatorGap
        anchors.horizontalCenter: parent.horizontalCenter
        count: root.runningCount
        indicatorWidth: root.indicatorWidth
        indicatorHeight: root.indicatorHeight
    }

    DockItemMenu {
        id: menu
        anchorWindow: root.panelWindow
        anchorItem: root
        controller: root.panelWindow
    }
}
