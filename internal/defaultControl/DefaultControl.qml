import QtQuick
import "../../pkg/ipc" as IPC

QtObject {
    id: defaultControl

    property var ipc: IPC.IPC

    // Main control dispatcher
    function control(item, state) {
        var windowCount = item.getWindowCount()

        if (windowCount === 0) {
            // Launch application
            launchApplication(item)
        } else if (windowCount === 1) {
            // Focus the window
            var address = Object.keys(item.windows)[0]
            focusWindow(address)
        } else {
            // Show windows menu
            showWindowsMenu(item)
        }
    }

    function launchApplication(item) {
        if (item.app && typeof item.app.launch === "function") {
            item.app.launch()
        }
    }

    function focusWindow(address) {
        ipc.dispatch("focuswindow address:" + address, function(error) {
            if (error) {
                console.error("Failed to focus window:", error)
            }
        })
    }

    function showWindowsMenu(item) {
        // Create context menu with windows list
        var menu = Qt.createQmlObject("
            import QtQuick
            import QtQuick.Controls
            Menu {
                id: contextMenu
            }
        ", defaultControl)

        var windows = Object.keys(item.windows)
        for (var i = 0; i < windows.length; i++) {
            var address = windows[i]
            var window = item.windows[address]
            var title = window.title || "Untitled"

            // Add menu item
            var menuItem = Qt.createQmlObject("
                import QtQuick
                import QtQuick.Controls
                MenuItem {
                    text: '" + title + "'
                    onClicked: {
                        // Focus this window
                    }
                }
            ", menu)

            menu.addItem(menuItem)
        }

        // Show menu at button location
        showContextMenu(menu, item.button)
    }

    function showContextMenu(menu, button) {
        if (menu && typeof menu.open === "function") {
            // Position menu near button
            menu.open()
        }
    }

    // Helper functions
    function getMenuPosition(button) {
        if (!button) return { x: 0, y: 0 }

        var globalPos = button.mapToGlobal(0, 0)
        return {
            x: globalPos.x + button.width / 2,
            y: globalPos.y + button.height / 2
        }
    }
}
