import QtQuick

QtObject {
    id: desktopApp

    // Desktop app properties
    property string className: ""
    property var name: ({})
    property var comment: ({})
    property string icon: ""
    property string exec: ""
    property bool singleWindow: false
    property var actions: []
    property var raw: ({})

    function create(className, language) {
        var app = Qt.createQmlObject("
            import QtQuick
            import 'Desktop.qml' as Desktop
            Desktop.DesktopApp {}
        ", desktopApp)
        
        app.className = className
        app.loadFromFile()
        return app
    }

    function loadFromFile() {
        var desktopFilePath = searchDesktopFile(className)
        if (!desktopFilePath) {
            // Use defaults
            setDefaults()
            return
        }

        var iniData = INI.INIManager.parse(desktopFilePath)
        if (!iniData) {
            setDefaults()
            return
        }

        raw = iniData
        var desktopEntry = iniData["Desktop Entry"] || {}

        // Parse localized strings
        name = getLocalizedString(iniData, "Name", className)
        comment = getLocalizedString(iniData, "Comment", className)
        icon = desktopEntry["Icon"] || className
        exec = desktopEntry["Exec"] || className
        singleWindow = desktopEntry["SingleWindow"] === "true"

        // Parse actions
        parseActions(desktopEntry)
    }

    function setDefaults() {
        name = { "": className }
        comment = { "": className }
        icon = className
        exec = className
        singleWindow = false
        actions = []
    }

    function getLocalizedString(iniData, key, defaultValue) {
        var result = {}
        var desktopEntry = iniData["Desktop Entry"] || {}

        // Try to get all locale variants
        var locales = ["", "_en", "_en_US", "_en_GB", "_C"]
        for (var i = 0; i < locales.length; i++) {
            var localeKey = key + locales[i]
            if (desktopEntry[localeKey]) {
                result[locales[i]] = desktopEntry[localeKey]
            }
        }

        // Fallback to non-localized or default
        if (!result[""] && desktopEntry[key]) {
            result[""] = desktopEntry[key]
        } else if (!result[""]) {
            result[""] = defaultValue
        }

        return result
    }

    function parseActions(desktopEntry) {
        var actionList = desktopEntry["Actions"]
        if (!actionList) {
            actions = []
            return
        }

        var actionNames = actionList.split(";").map(function(a) { return a.trim() }).filter(function(a) { return a.length > 0 })
        actions = []

        for (var i = 0; i < actionNames.length; i++) {
            var actionName = actionNames[i]
            var action = {
                name: getLocalizedString(raw, "Name[" + actionName + "]", actionName),
                exec: raw[actionName + " Desktop Action"] ? (raw[actionName + " Desktop Action"]["Exec"] || "") : "",
                icon: raw[actionName + " Desktop Action"] ? (raw[actionName + " Desktop Action"]["Icon"] || "") : ""
            }
            actions.push(action)
        }
    }

    function searchDesktopFile(className) {
        // Search for .desktop file in standard locations
        var searchPaths = [
            Qt.platform.os === "windows" ? "" : "/usr/share/applications",
            Qt.platform.os === "windows" ? "" : "/usr/local/share/applications",
            Qt.platform.os === "windows" ? "" : (getHomeDir() + "/.local/share/applications")
        ]

        // Try direct match
        for (var i = 0; i < searchPaths.length; i++) {
            var path = searchPaths[i] + "/" + className + ".desktop"
            if (fileExists(path)) {
                return path
            }
        }

        // Try with namespaces
        var namespaces = ["org.kde.", "net.project.", "com."]
        for (var j = 0; j < namespaces.length; j++) {
            for (var i = 0; i < searchPaths.length; i++) {
                var path = searchPaths[i] + "/" + namespaces[j] + className + ".desktop"
                if (fileExists(path)) {
                    return path
                }
            }
        }

        return null
    }

    function fileExists(path) {
        try {
            var xhr = new XMLHttpRequest()
            xhr.open("HEAD", "file://" + path, false)
            xhr.send()
            return xhr.status === 200
        } catch (e) {
            return false
        }
    }

    function getHomeDir() {
        return Qt.platform.os === "windows" ? 
            java.lang.System.getProperty("user.home") :
            (typeof process !== "undefined" && process.env ? process.env.HOME : "/root")
    }

    function getName(locale) {
        locale = locale || ""
        return name[locale] || name[""] || className
    }

    function getComment(locale) {
        locale = locale || ""
        return comment[locale] || comment[""] || className
    }

    function getIcon() {
        return icon
    }

    function getExec() {
        return exec
    }

    function isSingleWindow() {
        return singleWindow
    }

    function getActions() {
        return actions
    }

    function launch() {
        var execCommand = cleanExec(exec)
        executeCommand(execCommand)
    }

    function cleanExec(execString) {
        // Remove desktop file field codes (%f, %u, %i, %c, %k, %v, %m)
        return execString
            .replace(/%[fuickvdDnNvm]/g, "")
            .replace(/%%/g, "%")
            .trim()
    }

    function executeCommand(command) {
        try {
            var process = Qt.createQmlObject("
                import QtQuick
                QtObject {
                    function execute(cmd) {
                        // Execute via shell
                    }
                }
            ", desktopApp)
            process.execute(command)
        } catch (e) {
            console.error("Failed to execute command:", command, e)
        }
    }
}
