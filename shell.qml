import QtQuick
import Quickshell
import QtQuick.Layouts
import "cmd/hypr-dock" as Main
import "internal/state" as State
import "internal/settings" as Settings
import "internal/hypr/hyprEvents" as HyprEvents

ShellRoot {
    id: shellRoot

    // Initialize state manager
    property var state: State.State {}
    property var settings: Settings.Settings {}
    property var hyprEvents: null

    Component.onCompleted: {
        // Initialize settings
        settings.init()

        // Initialize app state
        state.init(settings)

        // Build and display main window
        Main.MainWindow { }

        // Start Hyprland event listener
        hyprEvents = HyprEvents.HyprEvents.createObject()
        hyprEvents.startListening()
    }
}
