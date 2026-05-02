import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../services"

PanelWindow {
    id: root

    property int iconSize: Settings.iconSize
    property int spacing: Settings.spacing
    property int outerPadding: 5
    property int itemPadding: 4
    property int radius: 12
    property int edgeMargin: Settings.margin
    property color bgColor: Qt.rgba(42 / 255, 41 / 255, 49 / 255, 0.473)

    property Item hoveredButton: null
    property var hoveredEntry: null
    property var activeMenu: null

    function requestMenuOpen(menu) {
        if (activeMenu && activeMenu !== menu) activeMenu.close();
        showTimer.stop();
        hideTimer.stop();
        preview.externallyShown = false;
        activeMenu = menu;
        menu.open();
    }

    function requestPreviewOpen() {
        if (activeMenu) {
            activeMenu.close();
            activeMenu = null;
        }
        preview.externallyShown = true;
    }

    function notifyMenuClosed(menu) {
        if (activeMenu === menu) activeMenu = null;
    }

    color: "transparent"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "hypr-dock"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    exclusionMode: Settings.exclusive ? ExclusionMode.Auto : ExclusionMode.Ignore

    anchors {
        bottom: true
    }
    margins {
        bottom: root.edgeMargin
    }

    implicitWidth: dockBg.implicitWidth
    implicitHeight: dockBg.implicitHeight

    Rectangle {
        id: dockBg
        anchors.centerIn: parent
        color: root.bgColor
        radius: root.radius
        implicitWidth: itemsRow.implicitWidth + root.outerPadding * 2
        implicitHeight: itemsRow.implicitHeight + root.outerPadding * 2

        RowLayout {
            id: itemsRow
            anchors.centerIn: parent
            spacing: root.spacing

            Repeater {
                model: DockModel.items
                delegate: DockItem {
                    required property var modelData
                    item: modelData
                    panelWindow: root
                    iconSize: root.iconSize
                    itemPadding: root.itemPadding
                    radius: root.radius

                    onHoverChanged: (entered, button, entry) => {
                        if (entered) {
                            root.hoveredButton = button;
                            root.hoveredEntry = entry;
                            hideTimer.stop();
                            const hasWindows = entry && entry.toplevels && entry.toplevels.length > 0;
                            if (hasWindows && !root.activeMenu) {
                                showTimer.restart();
                            } else {
                                preview.externallyShown = false;
                            }
                        } else if (root.hoveredButton === button) {
                            showTimer.stop();
                            hideTimer.restart();
                        }
                    }
                }
            }
        }
    }

    Timer {
        id: showTimer
        interval: 500
        onTriggered: {
            if (root.activeMenu) return;
            const e = root.hoveredEntry;
            if (e && e.toplevels && e.toplevels.length > 0) {
                root.requestPreviewOpen();
            }
        }
    }

    Timer {
        id: hideTimer
        interval: 350
        onTriggered: {
            if (!preview.hovered) preview.externallyShown = false;
        }
    }

    WindowPreviewPopup {
        id: preview
        anchorWindow: root
        anchorItem: root.hoveredButton
        toplevels: root.hoveredEntry && root.hoveredEntry.toplevels
            ? root.hoveredEntry.toplevels : []
        fallbackName: root.hoveredEntry ? root.hoveredEntry.name : ""
        fallbackIcon: root.hoveredEntry ? root.hoveredEntry.icon : ""
        onHoveredChanged: {
            if (hovered) hideTimer.stop();
            else if (!root.hoveredButton) hideTimer.restart();
        }
    }

    HyprlandFocusGrab {
        id: dismissGrab
        windows: root.activeMenu ? [root, root.activeMenu] : [root]
        active: !!root.activeMenu
        onCleared: {
            if (root.activeMenu) root.activeMenu.close();
        }
    }
}
