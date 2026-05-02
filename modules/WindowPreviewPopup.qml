import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets

PopupWindow {
    id: root

    property var anchorWindow
    property Item anchorItem
    property var toplevels: []
    property string fallbackName: ""
    property string fallbackIcon: ""
    property bool externallyShown: false
    property bool hovered: hoverArea.containsMouse

    readonly property bool shouldShow:
        externallyShown && (anchorItem !== null) && toplevels.length > 0

    readonly property int previewMaxWidth: 220
    readonly property int previewMaxHeight: 130
    readonly property int gapToItem: 8

    visible: shouldShow || hovered
    color: "transparent"
    implicitWidth: bg.implicitWidth
    implicitHeight: bg.implicitHeight

    anchor {
        window: root.anchorWindow
        item: root.anchorItem
        rect.x: 0
        rect.y: -root.gapToItem
        rect.width: root.anchorItem ? root.anchorItem.width : 0
        rect.height: 0
        gravity: Edges.Top
        edges: Edges.Bottom
        adjustment: PopupAdjustment.SlideX
    }

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: 12
        color: Qt.rgba(42 / 255, 41 / 255, 49 / 255, 0.94)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.06)

        implicitWidth: previewRow.implicitWidth + 16
        implicitHeight: previewRow.implicitHeight + 16

        MouseArea {
            id: hoverArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
        }

        RowLayout {
            id: previewRow
            anchors.centerIn: parent
            spacing: 8

            Repeater {
                model: root.toplevels

                ColumnLayout {
                    id: cell
                    required property var modelData
                    spacing: 4

                    Text {
                        Layout.fillWidth: true
                        Layout.maximumWidth: root.previewMaxWidth
                        text: cell.modelData ? (cell.modelData.title || root.fallbackName) : ""
                        color: Qt.rgba(1, 1, 1, 0.92)
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }

                    Rectangle {
                        Layout.preferredWidth: root.previewMaxWidth
                        Layout.preferredHeight: root.previewMaxHeight
                        color: Qt.rgba(0, 0, 0, 0.3)
                        radius: 6
                        clip: true

                        ScreencopyView {
                            id: capture
                            anchors.fill: parent
                            captureSource: cell.modelData
                            live: true
                            paintCursor: false
                            constraintSize: Qt.size(root.previewMaxWidth, root.previewMaxHeight)
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (cell.modelData) cell.modelData.activate();
                            }
                        }
                    }
                }
            }
        }
    }
}
