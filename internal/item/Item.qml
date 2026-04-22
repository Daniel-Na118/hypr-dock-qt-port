import QtQuick
import QtQuick.Layouts
import "../../internal/desktop" as Desktop

Rectangle {
    id: itemContainer

    property string className: ""
    property var app: null
    property var windows: ({})
    property var button: null
    property var indicatorImage: null
    property var settings: null
    property var list: null
    property var pinnedList: null

    width: settings ? settings.iconSize + 10 : 58
    height: width
    color: "transparent"

    // Store window count
    property int windowCount: Object.keys(windows).length

    onWindowCountChanged: {
        if (indicatorImage) {
            indicatorImage.updateCount(windowCount)
        }
    }

    Component.onCompleted: {
        loadAppData()
        createUI()
    }

    function loadAppData() {
        app = Desktop.DesktopApp.create(className)
    }

    function createUI() {
        // Create button with icon
        var buttonArea = Qt.createQmlObject("
            import QtQuick
            import QtQuick.Controls
            Button {
                id: itemButton
                width: parent.width - 4
                height: parent.height - 4
                anchors.centerIn: parent
                
                ToolTip.visible: hovered
                ToolTip.text: itemContainer.app ? itemContainer.app.getName() : itemContainer.className
                
                onClicked: {
                    itemContainer.handleClick()
                }
            }
        ", itemContainer)

        button = buttonArea
    }

    function addWindow(ipcClient) {
        if (ipcClient && ipcClient.address) {
            windows[ipcClient.address] = ipcClient
            windowCountChanged()
        }
    }

    function removeWindow(windowAddress) {
        if (windows[windowAddress]) {
            delete windows[windowAddress]
            windowCountChanged()
        }
    }

    function updateWindowTitle(address, title) {
        if (windows[address]) {
            windows[address].title = title
        }
    }

    function getWindowCount() {
        return windowCount
    }

    function handleClick() {
        var count = getWindowCount()

        if (count === 0) {
            // Launch application
            launchApp()
        } else if (count === 1) {
            // Focus the single window
            focusWindow(Object.keys(windows)[0])
        } else {
            // Show windows menu
            showWindowsMenu()
        }
    }

    function launchApp() {
        if (app) {
            app.launch()
        }
    }

    function focusWindow(address) {
        // Dispatch focus command to Hyprland
        var cmd = "focuswindow address:" + address
        // Send via IPC
    }

    function showWindowsMenu() {
        // Show context menu with windows
        var menu = Qt.createQmlObject("
            import QtQuick
            import QtQuick.Controls
            Menu {
                id: windowMenu
            }
        ", itemContainer)

        // Add window items to menu
        for (var address in windows) {
            if (windows.hasOwnProperty(address)) {
                var window = windows[address]
                var title = window.title || "Untitled"
                // Add menu item
            }
        }

        // Show menu
        // menu.open()
    }
}
