import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
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
                }
            }
        }
    }
}
