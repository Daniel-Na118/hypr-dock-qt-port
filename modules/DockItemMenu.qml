import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

PopupWindow {
    id: root

    // Required:
    property var anchorWindow                 // PanelWindow above which we anchor
    property Item anchorItem                  // dock item rectangle
    // Row schema: { kind: "row" | "separator", label, icon, enabled, onTriggered, indent }
    property var rows: []

    readonly property int rowHeight: 22
    readonly property int separatorHeight: 7
    readonly property int hPadding: 10
    readonly property int vPadding: 6
    readonly property int gapToItem: 6

    function open() { visible = true; }
    function close() { visible = false; }
    function trigger(row) {
        if (!row || row.kind === "separator") return;
        if (row.enabled === false) return;
        close();
        if (typeof row.onTriggered === "function") row.onTriggered();
    }

    visible: false
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
        color: Qt.rgba(42 / 255, 41 / 255, 49 / 255, 0.92)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.06)

        implicitWidth: column.implicitWidth + root.hPadding * 2
        implicitHeight: column.implicitHeight + root.vPadding * 2

        ColumnLayout {
            id: column
            anchors.fill: parent
            anchors.margins: root.vPadding
            spacing: 0

            Repeater {
                model: root.rows
                delegate: Loader {
                    required property var modelData
                    Layout.fillWidth: true
                    sourceComponent: modelData.kind === "separator" ? sepComp : rowComp

                    Component {
                        id: sepComp
                        Item {
                            implicitHeight: root.separatorHeight
                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.leftMargin: root.hPadding - 4
                                anchors.rightMargin: root.hPadding - 4
                                height: 1
                                color: Qt.rgba(1, 1, 1, 0.08)
                            }
                        }
                    }

                    Component {
                        id: rowComp
                        Rectangle {
                            implicitHeight: root.rowHeight
                            radius: 6
                            color: hover.containsMouse && (modelData.enabled !== false)
                                ? Qt.rgba(1, 1, 1, 0.07) : "transparent"

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: root.hPadding - 4 + (modelData.indent ? 14 : 0)
                                anchors.rightMargin: root.hPadding - 4
                                spacing: 8

                                IconImage {
                                    visible: !!modelData.icon
                                    anchors.verticalCenter: parent.verticalCenter
                                    implicitSize: 14
                                    source: modelData.icon
                                        ? Quickshell.iconPath(modelData.icon, "image-missing") : ""
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: modelData.label || ""
                                    color: (modelData.enabled === false)
                                        ? Qt.rgba(1, 1, 1, 0.35) : Qt.rgba(1, 1, 1, 0.92)
                                    font.pixelSize: 12
                                    elide: Text.ElideRight
                                }
                            }

                            MouseArea {
                                id: hover
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.LeftButton
                                cursorShape: (modelData.enabled === false)
                                    ? Qt.ArrowCursor : Qt.PointingHandCursor
                                onClicked: root.trigger(modelData)
                            }
                        }
                    }
                }
            }
        }
    }
}
