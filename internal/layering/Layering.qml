import QtQuick

QtObject {
    id: layeringControl

    property var window: null
    property var settings: null
    property bool isVisible: true
    property var hideTimer: null
    property var showTimer: null

    // Configure Wayland layer shell for window
    function configureWindow(win, settings) {
        layeringControl.window = win
        layeringControl.settings = settings

        // Set window properties based on position
        switch (settings.position) {
            case "top":
                configureTopDock()
                break
            case "bottom":
                configureBottomDock()
                break
            case "left":
                configureLeftDock()
                break
            case "right":
                configureRightDock()
                break
            default:
                configureBottomDock()
        }

        // Set layer shell properties
        if (win.x11Ignore) {
            win.x11Ignore = true
        }

        // Set window hints
        if (typeof win.setWindowProperty === "function") {
            win.setWindowProperty("_NET_WM_WINDOW_TYPE", "_NET_WM_WINDOW_TYPE_DOCK")
        }
    }

    function configureTopDock() {
        if (!window) return

        window.y = 0
        window.x = 0
        window.width = Qt.binding(function() { return screen ? screen.width : 1920 })
        window.height = settings.iconSize + settings.margin * 2

        setLayerProperties("top", "background")
    }

    function configureBottomDock() {
        if (!window) return

        window.y = Qt.binding(function() { return screen ? screen.height - (settings.iconSize + settings.margin * 2) : 1080 - 68 })
        window.x = 0
        window.width = Qt.binding(function() { return screen ? screen.width : 1920 })
        window.height = settings.iconSize + settings.margin * 2

        setLayerProperties("bottom", "background")
    }

    function configureLeftDock() {
        if (!window) return

        window.x = 0
        window.y = 0
        window.width = settings.iconSize + settings.margin * 2
        window.height = Qt.binding(function() { return screen ? screen.height : 1080 })

        setLayerProperties("left", "background")
    }

    function configureRightDock() {
        if (!window) return

        window.x = Qt.binding(function() { return screen ? screen.width - (settings.iconSize + settings.margin * 2) : 1920 - 68 })
        window.y = 0
        window.width = settings.iconSize + settings.margin * 2
        window.height = Qt.binding(function() { return screen ? screen.height : 1080 })

        setLayerProperties("right", "background")
    }

    function setLayerProperties(anchor, layer) {
        // In QuickShell, layer shell properties are set via window properties
        if (typeof window.setProperty === "function") {
            window.setProperty("layer", layer)
            window.setProperty("anchor", anchor)
            window.setProperty("exclusive_zone", settings.iconSize + settings.margin * 2)
        }
    }

    function getOrientation() {
        if (settings.position === "left" || settings.position === "right") {
            return "Vertical"
        }
        return "Horizontal"
    }

    function toggleVisibility() {
        isVisible = !isVisible
        if (window) {
            window.visible = isVisible
        }
    }

    function show() {
        isVisible = true
        if (window) {
            window.visible = true
            cancelHideTimer()
        }
    }

    function hide() {
        isVisible = false
        if (window) {
            window.visible = false
        }
    }

    function setAutoHideTimer(delayMs) {
        if (hideTimer) {
            hideTimer.stop()
            hideTimer.destroy()
        }

        hideTimer = Qt.createQmlObject("
            import QtQuick
            Timer {
                interval: " + delayMs + "
                running: true
                repeat: false
                onTriggered: {
                    // Hide dock
                }
            }
        ", layeringControl)
    }

    function cancelHideTimer() {
        if (hideTimer) {
            hideTimer.stop()
            hideTimer.destroy()
            hideTimer = null
        }
    }
}
