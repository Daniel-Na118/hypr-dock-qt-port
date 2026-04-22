import QtQuick
import QtQuick.Layouts
import "../../internal/item" as Item
import "../../internal/itemsctl" as ItemsCtl
import "../../pkg/ipc" as IPC

Rectangle {
    id: appContainer

    property var state: null
    property var settings: null
    property var itemsBox: null
    property var clients: []

    color: "transparent"

    Layout.fillWidth: true
    Layout.fillHeight: true

    Component.onCompleted: {
        buildApp()
    }

    function buildApp() {
        var state = parent.state
        var settings = state.getSettings()

        // Create items box with proper orientation
        var orientation = settings.position === "left" || settings.position === "right" ? 
            Qt.Vertical : Qt.Horizontal

        itemsBox = Qt.createQmlObject("
            import QtQuick
            import QtQuick.Layouts
            Rectangle {
                id: itemsBoxRect
                color: 'transparent'
                
                RowLayout {
                    id: layout
                    anchors.fill: parent
                    spacing: " + settings.spacing + "
                }
            }
        ", appContainer)

        // Set margins
        setMargins(settings, itemsBox)

        // Store reference in state
        state.setItemsBox(itemsBox)

        // Render items
        renderItems(state)
    }

    function setMargins(settings, box) {
        // Apply margins based on position
        var margin = settings.margin || 10

        if (settings.position === "left" || settings.position === "right") {
            // Vertical dock
            box.anchors.topMargin = margin
            box.anchors.bottomMargin = margin
        } else {
            // Horizontal dock
            box.anchors.leftMargin = margin
            box.anchors.rightMargin = margin
        }
    }

    function renderItems(state) {
        var settings = state.getSettings()
        var list = state.getList()
        var pinned = state.getPinned()

        // Clear existing items
        list.clear()

        // Add pinned items
        for (var i = 0; i < pinned.length; i++) {
            initNewItemInClass(pinned[i], state)
        }

        // Add running window items
        IPC.IPC.getClients(function(clients) {
            if (!clients) clients = []
            
            for (var j = 0; j < clients.length; j++) {
                initNewItemInIPC(clients[j], state)
            }
        })
    }

    function initNewItemInClass(className, state) {
        if (!className || className.length === 0) return

        var list = state.getList()
        var existing = list.get(className)

        if (!existing) {
            var item = createItem(className, state)
            list.add(className, item)
            addItemToUI(item)
        }
    }

    function initNewItemInIPC(ipcClient, state) {
        if (!ipcClient) return

        var list = state.getList()
        var className = ipcClient.class || ipcClient.initialTitle || "Unknown"
        var pinned = state.getPinned()
        var isPin = pinned.indexOf(className) >= 0
        var added = list.get(className) !== null

        if (!isPin && !added) {
            initNewItemInClass(className, state)
        }

        var item = list.get(className)
        if (item) {
            item.addWindow(ipcClient)
        }
    }

    function createItem(className, state) {
        var settings = state.getSettings()
        var item = Qt.createQmlObject("
            import QtQuick
            import 'Item.qml' as Item
            Item.Item {}
        ", appContainer)

        item.className = className
        item.settings = settings
        item.list = state.getList()
        item.pinnedList = state.getPinned()

        return item
    }

    function addItemToUI(item) {
        // Add item component to items box layout
        if (itemsBox) {
            // Insert into layout
            // itemsBox.children.push(item)
        }
    }

    function refresh() {
        // Rebuild items
        buildApp()
    }

    Connections {
        target: state
        function onItemsChanged() {
            refresh()
        }
    }
}
