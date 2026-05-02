import QtQuick
import Quickshell
import Quickshell.Widgets

PopupWindow {
    id: root

    property var anchorWindow                 // PanelWindow
    property Item anchorItem                  // dock item rect
    property var controller                   // optional: must have notifyMenuClosed(menu)
    // rows: [{ kind: "row" | "separator", label, icon, onTriggered }]
    property var rows: []

    onVisibleChanged: {
        if (!visible && controller && controller.notifyMenuClosed) {
            controller.notifyMenuClosed(root);
        }
    }

    readonly property int rowHeight: 24
    readonly property int separatorHeight: 7
    readonly property int rowHPadding: 10
    readonly property int rowVPadding: 6
    readonly property int outerPadding: 6
    readonly property int gapToItem: 8
    readonly property int iconSize: 14
    readonly property int textIconSpacing: 8
    readonly property int minRowWidth: 140
    readonly property int maxRowWidth: 320

    function open() { visible = true; }
    function close() { visible = false; }
    function trigger(row) {
        if (!row || row.kind === "separator") return;
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
        color: Qt.rgba(42 / 255, 41 / 255, 49 / 255, 0.94)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.06)

        implicitWidth: Math.min(root.maxRowWidth,
            Math.max(root.minRowWidth, column.implicitWidth)) + root.outerPadding * 2
        implicitHeight: column.implicitHeight + root.outerPadding * 2

        Column {
            id: column
            x: root.outerPadding
            y: root.outerPadding
            width: bg.width - root.outerPadding * 2
            spacing: 0

            Repeater {
                model: root.rows

                Item {
                    id: rowRoot
                    required property var modelData
                    readonly property bool isSeparator: modelData.kind === "separator"

                    width: column.width
                    implicitWidth: isSeparator
                        ? root.minRowWidth
                        : (root.rowHPadding * 2
                           + (modelData.icon ? root.iconSize + root.textIconSpacing : 0)
                           + label.implicitWidth)
                    implicitHeight: isSeparator ? root.separatorHeight : root.rowHeight

                    // Separator
                    Rectangle {
                        visible: rowRoot.isSeparator
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: root.rowHPadding - 4
                        anchors.rightMargin: root.rowHPadding - 4
                        height: 1
                        color: Qt.rgba(1, 1, 1, 0.10)
                    }

                    // Row
                    Rectangle {
                        visible: !rowRoot.isSeparator
                        anchors.fill: parent
                        radius: 6
                        color: hover.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"

                        IconImage {
                            id: rowIcon
                            visible: !!rowRoot.modelData.icon
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: root.rowHPadding
                            implicitSize: root.iconSize
                            source: rowRoot.modelData.icon
                                ? Quickshell.iconPath(rowRoot.modelData.icon, "image-missing")
                                : ""
                        }

                        Text {
                            id: label
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: rowIcon.visible ? rowIcon.right : parent.left
                            anchors.leftMargin: rowIcon.visible ? root.textIconSpacing : root.rowHPadding
                            anchors.right: parent.right
                            anchors.rightMargin: root.rowHPadding
                            text: rowRoot.modelData.label || ""
                            color: Qt.rgba(1, 1, 1, 0.92)
                            font.pixelSize: 12
                            elide: Text.ElideRight
                        }

                        MouseArea {
                            id: hover
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.LeftButton
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.trigger(rowRoot.modelData)
                        }
                    }
                }
            }
        }
    }
}
