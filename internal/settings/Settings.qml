import QtQuick
import "../../pkg/ini" as INI

QtObject {
    id: settings

    // Settings properties
    property string position: "bottom"
    property int spacing: 10
    property int iconSize: 48
    property int margin: 10
    property string themeDir: ""
    property string configDir: ""
    property string localDir: ""
    property string configPath: ""
    property string pinnedPath: ""
    property var pinnedApps: []
    property var config: null

    // Initialize settings
    function init() {
        var home = Qt.binding(function() { return getHomeDir() })
        
        // Set default paths
        settings.localDir = home + "/.local/share/hypr-dock"
        settings.configDir = home + "/.config/hypr-dock"
        settings.configPath = settings.configDir + "/hypr-dock.conf"
        settings.pinnedPath = settings.localDir + "/pinned"
        settings.themeDir = settings.configDir + "/themes"

        // Load configuration
        loadConfig()
        
        // Load pinned apps
        loadPinned()
    }

    function loadConfig() {
        // Load INI configuration file
        settings.config = INI.INIManager.load(settings.configPath)

        if (settings.config) {
            settings.position = settings.config.get("position", "bottom")
            settings.spacing = parseInt(settings.config.get("spacing", "10")) || 10
            settings.iconSize = parseInt(settings.config.get("icon_size", "48")) || 48
            settings.margin = parseInt(settings.config.get("margin", "10")) || 10
        }
    }

    function loadPinned() {
        // Load pinned apps from file
        var pinnedFile = readFile(settings.pinnedPath)
        if (pinnedFile) {
            settings.pinnedApps = pinnedFile.split("\n").filter(function(app) {
                return app.trim().length > 0
            })
        } else {
            settings.pinnedApps = []
        }
    }

    function savePinned(apps) {
        writeFile(settings.pinnedPath, apps.join("\n"))
        settings.pinnedApps = apps
    }

    function getHomeDir() {
        // Get home directory from environment
        return Qt.platform.os === "windows" ? 
            java.lang.System.getProperty("user.home") :
            Qt.binding(function() { return process.env.HOME || "/root" })
    }

    function readFile(path) {
        try {
            var xhr = new XMLHttpRequest()
            xhr.open("GET", "file://" + path, false)
            xhr.send()
            return xhr.responseText
        } catch (e) {
            console.error("Failed to read file:", path, e)
            return ""
        }
    }

    function writeFile(path, content) {
        try {
            var xhr = new XMLHttpRequest()
            xhr.open("PUT", "file://" + path, false)
            xhr.send(content)
        } catch (e) {
            console.error("Failed to write file:", path, e)
        }
    }
}
