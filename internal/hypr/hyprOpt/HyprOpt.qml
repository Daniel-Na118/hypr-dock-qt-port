import QtQuick
import "../../pkg/ipc" as IPC

QtObject {
    id: hyprOpt

    property var ipc: IPC.IPC
    property var optionCache: ({})

    // Get Hyprland option value
    function getOption(optionName, callback) {
        // Check cache first
        if (optionCache[optionName]) {
            if (callback) callback(optionCache[optionName])
            return
        }

        // Get from Hyprland
        ipc.getOption(optionName, function(result) {
            if (result) {
                optionCache[optionName] = result
                if (callback) callback(result)
            }
        })
    }

    // Get layout
    function getLayout(callback) {
        getOption("general:layout", callback)
    }

    // Get gaps
    function getGaps(callback) {
        getOption("general:gaps_in", callback)
    }

    // Get border size
    function getBorderSize(callback) {
        getOption("general:border_size", callback)
    }

    // Clear cache
    function clearCache() {
        optionCache = {}
    }
}
