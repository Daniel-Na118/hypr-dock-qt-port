import QtQuick
import "../../pkg/ipc" as IPC

QtObject {
    id: hyprEvents

    property var appState: null
    property var ipcManager: IPC.IPC

    // Signals for events
    signal windowTitleChanged(string address, string title)
    signal windowOpened(var windowData)
    signal windowClosed(string address)
    signal specialWorkspaceActivated(string workspace)

    // Event handlers map
    property var eventHandlers: ({})

    function startListening() {
        // Register event listeners
        registerWindowTitleListener()
        registerOpenWindowListener()
        registerCloseWindowListener()
        registerSpecialWorkspaceListener()

        // Start polling for events
        var eventTimer = Qt.createQmlObject("
            import QtQuick
            Timer {
                interval: 100
                running: true
                repeat: true
                onTriggered: {
                    // Poll for events
                }
            }
        ", hyprEvents)
    }

    function registerWindowTitleListener() {
        ipcManager.addEventListener("windowtitlev2", function(event) {
            var parts = event.split(">>")
            if (parts.length >= 2) {
                var address = parts[1].trim()
                var title = parts.slice(2).join(">>").trim()
                windowTitleChanged(address, title)
                onWindowTitleChanged(address, title)
            }
        })
    }

    function registerOpenWindowListener() {
        ipcManager.addEventListener("openwindow", function(event) {
            var parts = event.split(">>")
            if (parts.length >= 2) {
                var data = JSON.parse("{" + parts.slice(1).join(">>") + "}")
                windowOpened(data)
                onWindowOpened(data)
            }
        })
    }

    function registerCloseWindowListener() {
        ipcManager.addEventListener("closewindow", function(event) {
            var parts = event.split(">>")
            if (parts.length >= 2) {
                var address = parts[1].trim()
                windowClosed(address)
                onWindowClosed(address)
            }
        })
    }

    function registerSpecialWorkspaceListener() {
        ipcManager.addEventListener("activespecial", function(event) {
            var parts = event.split(">>")
            if (parts.length >= 2) {
                var workspace = parts[1].trim()
                specialWorkspaceActivated(workspace)
                onSpecialWorkspaceActivated(workspace)
            }
        })
    }

    function onWindowTitleChanged(address, title) {
        console.log("Window title changed:", address, title)
        if (appState) {
            var item = appState.getList().searchWindow(address)
            if (item) {
                item.updateWindowTitle(address, title)
            }
        }
    }

    function onWindowOpened(windowData) {
        console.log("Window opened:", windowData)
        if (appState) {
            appState.updateItems()
        }
    }

    function onWindowClosed(address) {
        console.log("Window closed:", address)
        if (appState) {
            appState.updateItems()
        }
    }

    function onSpecialWorkspaceActivated(workspace) {
        console.log("Special workspace activated:", workspace)
        // Handle special workspace activation
    }
}
