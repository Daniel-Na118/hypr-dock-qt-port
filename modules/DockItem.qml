import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import "../services"

Item {
    id: root

    property var item                 // entry from DockModel.items
    property var panelWindow          // the Dock PanelWindow (for popup anchor)
    property int iconSize: 23
    property int itemPadding: 4
    property int radius: 12

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

    implicitWidth: iconSize + itemPadding * 2
    implicitHeight: iconSize + itemPadding * 2 + indicatorHeight + indicatorGap

    function _windowRows() {
        const rows = [];
        for (let i = 0; i < toplevels.length; ++i) {
            const t = toplevels[i];
            rows.push({
                kind: "row",
                label: t.title || displayName,
                onTriggered: () => HyprActions.focusToplevel(t)
            });
        }
        return rows;
    }

    function _showWindowsMenu() {
        if (!item) return;
        menu.rows = _windowRows();
        menu.open();
    }

    function _showContextMenu() {
        if (!item) return;
        const entry = item.desktopEntry;
        const rows = [];

        // Open windows
        rows.push.apply(rows, _windowRows());
        if (rows.length > 0) rows.push({ kind: "separator" });

        // Desktop actions
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

        // Launch new window
        if (entry) {
            const single = !!entry.singleMainWindow;
            rows.push({
                kind: "row",
                label: "Launch new window",
                enabled: !single,
                onTriggered: () => HyprActions.launch(entry)
            });
        }

        // Pin / Unpin
        rows.push({
            kind: "row",
            label: item.pinned ? "Unpin from dock" : "Pin to dock",
            onTriggered: () => PinnedStore.toggle(item.appId || item.key)
        });

        // Close window (only meaningful with exactly one window)
        if (toplevels.length === 1) {
            rows.push({ kind: "separator" });
            rows.push({
                kind: "row",
                label: "Close window",
                onTriggered: () => HyprActions.closeToplevel(toplevels[0])
            });
        }

        menu.rows = rows;
        menu.open();
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
            onClicked: mouse => {
                if (!root.item) return;
                if (mouse.button === Qt.LeftButton) {
                    if (root.runningCount === 0) {
                        HyprActions.launch(root.item.desktopEntry);
                    } else if (root.runningCount === 1) {
                        HyprActions.focusToplevel(root.toplevels[0]);
                    } else {
                        root._showWindowsMenu();
                    }
                } else if (mouse.button === Qt.RightButton) {
                    root._showContextMenu();
                }
            }
        }

        ToolTip.visible: hoverArea.containsMouse && !menu.visible && root.displayName.length > 0
        ToolTip.text: root.displayName
        ToolTip.delay: 500
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
    }
}
