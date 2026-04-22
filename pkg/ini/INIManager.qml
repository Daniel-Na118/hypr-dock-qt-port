import QtQuick

QtObject {
    id: iniManager

    // Parse INI file and return map
    function load(filePath) {
        var fileContent = readFile(filePath)
        if (!fileContent) return null

        return parse(filePath)
    }

    function parse(filePath) {
        var fileContent = readFile(filePath)
        if (!fileContent) return null

        var lines = fileContent.split("\n")
        var result = {}
        var currentSection = null

        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim()

            // Skip empty lines and comments
            if (!line || line.charAt(0) === "#" || line.charAt(0) === ";") {
                continue
            }

            // Check for section headers
            if (line.charAt(0) === "[" && line.charAt(line.length - 1) === "]") {
                currentSection = line.substring(1, line.length - 1).trim()
                result[currentSection] = {}
                continue
            }

            // Parse key=value pairs
            if (currentSection && line.indexOf("=") > -1) {
                var parts = line.split("=")
                var key = parts[0].trim()
                var value = parts.slice(1).join("=").trim()

                result[currentSection][key] = value
            }
        }

        return result
    }

    function get(key, defaultValue) {
        // Get value from first section with the key
        // This is a simplified version
        return defaultValue
    }

    function readFile(path) {
        try {
            var xhr = new XMLHttpRequest()
            xhr.open("GET", "file://" + path, false)
            xhr.send()
            if (xhr.status === 200 || xhr.status === 0) {
                return xhr.responseText
            }
        } catch (e) {
            console.error("Failed to read INI file:", path, e)
        }
        return null
    }

    function writeFile(path, content) {
        try {
            var xhr = new XMLHttpRequest()
            xhr.open("PUT", "file://" + path, false)
            xhr.send(content)
        } catch (e) {
            console.error("Failed to write INI file:", path, e)
        }
    }
}
