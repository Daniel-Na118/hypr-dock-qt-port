import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    // Visual constants pulled 1:1 from hypr-dock/configs/default
    property int iconSize: 23
    property int spacing: 5
    property int outerPadding: 5
    property int itemPadding: 4
    property int radius: 12
    property int edgeMargin: 8
    property color bgColor: Qt.rgba(42 / 255, 41 / 255, 49 / 255, 0.473)

    // Phase 1: hardcoded fake items so we can eyeball the visuals.
    property var fakeItems: [
        { icon: "firefox",                 count: 2 },
        { icon: "org.kde.dolphin",         count: 1 },
        { icon: "code",                    count: 0 },
        { icon: "org.telegram.desktop",    count: 3 },
        { icon: "spotify",                 count: 1 },
        { icon: "utilities-terminal",      count: 0 }
    ]

    color: "transparent"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "hypr-dock"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Auto

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
                model: root.fakeItems
                delegate: DockItem {
                    required property var modelData
                    iconName: modelData.icon
                    runningCount: modelData.count
                    iconSize: root.iconSize
                    itemPadding: root.itemPadding
                    radius: root.radius
                }
            }
        }
    }
}
