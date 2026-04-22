import QtQuick

QtObject {
    id: ipc

    property var eventListeners: ({})
    property var socket: null

    // Send command to Hyprland via IPC
    function hyprctl(cmd, callback) {
        try {
            var process = createProcess()
            var fullCmd = 'socat - UNIX-CONNECT:/tmp/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket.sock'
            
            process.onReadyReadStandardOutput.connect(function() {
                var output = process.readAllStandardOutput()
                if (callback) callback(null, output)
            })
            
            process.onReadyReadStandardError.connect(function() {
                var error = process.readAllStandardError()
                if (callback) callback(error, null)
            })
            
            process.start(fullCmd, [cmd])
        } catch (e) {
            console.error("Hyprctl error:", e)
            if (callback) callback(e, null)
        }
    }

    // Get all clients (windows)
    function getClients(callback) {
        hyprctl("j/clients", function(error, data) {
            if (error) {
                console.error("Failed to get clients:", error)
                if (callback) callback([])
                return
            }
            try {
                var clients = JSON.parse(data)
                if (callback) callback(clients)
            } catch (e) {
                console.error("Failed to parse clients JSON:", e)
                if (callback) callback([])
            }
        })
    }

    // Get all monitors
    function getMonitors(callback) {
        hyprctl("j/monitors", function(error, data) {
            if (error) {
                console.error("Failed to get monitors:", error)
                if (callback) callback([])
                return
            }
            try {
                var monitors = JSON.parse(data)
                if (callback) callback(monitors)
            } catch (e) {
                console.error("Failed to parse monitors JSON:", e)
                if (callback) callback([])
            }
        })
    }

    // Get active window
    function getActiveWindow(callback) {
        hyprctl("j/activewindow", function(error, data) {
            if (error) {
                console.error("Failed to get active window:", error)
                if (callback) callback(null)
                return
            }
            try {
                var window = JSON.parse(data)
                if (callback) callback(window)
            } catch (e) {
                console.error("Failed to parse active window JSON:", e)
                if (callback) callback(null)
            }
        })
    }

    // Get option value
    function getOption(option, callback) {
        var cmd = "j/getoption " + option
        hyprctl(cmd, function(error, data) {
            if (error) {
                console.error("Failed to get option:", option, error)
                if (callback) callback(null)
                return
            }
            try {
                var result = JSON.parse(data)
                if (callback) callback(result)
            } catch (e) {
                console.error("Failed to parse option JSON:", e)
                if (callback) callback(null)
            }
        })
    }

    // Dispatch command
    function dispatch(cmd, callback) {
        hyprctl("dispatch " + cmd, function(error, data) {
            if (error) {
                console.error("Dispatch error:", error)
            }
            if (callback) callback(error, data)
        })
    }

    // Start listening for Hyprland events
    function initHyprEvents(eventHandler) {
        // This would typically run in a separate process/thread
        // For now, we set up a timer to poll for events
        var timer = Qt.createQmlObject("
            import QtQuick; Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: {
                    ipc.checkEvents()
                }
            }
        ", ipc)
    }

    // Check for events
    function checkEvents() {
        // Implementation would connect to event socket and process events
        // This is a simplified version
    }

    // Add event listener
    function addEventListener(eventType, handler) {
        if (!eventListeners[eventType]) {
            eventListeners[eventType] = []
        }
        eventListeners[eventType].push(handler)
    }

    // Dispatch event
    function dispatchEvent(event) {
        var parts = event.split(">")
        if (parts.length > 0) {
            var eventType = parts[0].trim()
            if (eventListeners[eventType]) {
                eventListeners[eventType].forEach(function(handler) {
                    handler(event)
                })
            }
        }
    }

    function createProcess() {
        // Return a process object compatible with the runtime
        return Qt.createQmlObject("
            import QtQuick
            import Quickshell
            QtObject {
                signal onReadyReadStandardOutput()
                signal onReadyReadStandardError()
                function start(cmd, args) {}
                function readAllStandardOutput() { return '' }
                function readAllStandardError() { return '' }
            }
        ", ipc)
    }
}
