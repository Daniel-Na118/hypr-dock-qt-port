import QtQuick

QtObject {
    id: utils

    // Normalize title string
    function normaliseTitle(title) {
        if (!title) return "Unknown"
        return title.replace(/[^\w\s-]/g, "").trim()
    }

    // Parse window class from title
    function parseWindowClass(title) {
        var parts = title.split(/\s+/)
        if (parts.length > 0) {
            return parts[0].toLowerCase()
        }
        return "unknown"
    }

    // Get icon path
    function getIconPath(iconName) {
        var searchPaths = [
            "/usr/share/icons",
            "/usr/local/share/icons",
            getHomeDir() + "/.local/share/icons"
        ]

        for (var i = 0; i < searchPaths.length; i++) {
            var path = searchPaths[i] + "/hicolor/48x48/apps/" + iconName + ".png"
            if (fileExists(path)) {
                return path
            }
        }

        return null
    }

    // Check if file exists
    function fileExists(path) {
        try {
            var xhr = new XMLHttpRequest()
            xhr.open("HEAD", "file://" + path, false)
            xhr.send()
            return xhr.status === 200 || xhr.status === 0
        } catch (e) {
            return false
        }
    }

    // Get home directory
    function getHomeDir() {
        return typeof process !== "undefined" && process.env ? 
            process.env.HOME : "/root"
    }

    // Format bytes to human readable
    function formatBytes(bytes) {
        if (bytes === 0) return "0 B"
        var k = 1024
        var sizes = ["B", "KB", "MB", "GB"]
        var i = Math.floor(Math.log(bytes) / Math.log(k))
        return Math.round(bytes / Math.pow(k, i) * 100) / 100 + " " + sizes[i]
    }
}
