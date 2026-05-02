import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import "../services"

Item {
    id: root

    property var item                 // entry from DockModel.items
    property int iconSize: 23
    property int itemPadding: 4
    property int radius: 12

    readonly property string iconName: item ? item.icon : ""
    readonly property string displayName: item ? item.name : ""
    readonly property int runningCount: item && item.toplevels ? item.toplevels.length : 0

    readonly property int indicatorWidth: Math.round(iconSize * 0.56)
    readonly property int indicatorHeight: Math.max(2, Math.round(indicatorWidth * 9 / 48))
    readonly property int indicatorGap: 1

    implicitWidth: iconSize + itemPadding * 2
    implicitHeight: iconSize + itemPadding * 2 + indicatorHeight + indicatorGap

    Rectangle {
        id: button
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: root.iconSize + root.itemPadding * 2
        height: root.iconSize + root.itemPadding * 2
        radius: root.radius
        color: hoverArea.containsMouse ? Qt.rgba(1, 1, 1, 0.06) : "transparent"

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
            onClicked: mouse => {
                if (mouse.button === Qt.LeftButton) {
                    HyprActions.activate(root.item);
                } else if (mouse.button === Qt.RightButton && root.item) {
                    PinnedStore.toggle(root.item.appId || root.item.key);
                }
            }
        }

        ToolTip.visible: hoverArea.containsMouse && root.displayName.length > 0
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
}
