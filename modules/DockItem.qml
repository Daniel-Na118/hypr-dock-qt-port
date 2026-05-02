import QtQuick
import Quickshell.Widgets

Item {
    id: root

    property string iconName: ""
    property int runningCount: 0
    property int iconSize: 23
    property int itemPadding: 4
    property int radius: 12

    // Indicator dimensions: width = iconSize * 0.56, original SVG aspect 48:9.
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
            source: root.iconName ? Quickshell.iconPath(root.iconName, true) : ""
        }

        MouseArea {
            id: hoverArea
            anchors.fill: parent
            hoverEnabled: true
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
}
