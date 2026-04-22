import QtQuick
import Quickshell
import QtQuick.Layouts
import "../../internal/app" as App
import "../../internal/layering" as Layering

Window {
    id: mainWindow

    title: "hypr-dock"
    visible: true
    x: 0
    y: 0

    // Get state from shell root
    property var state: parent.state
    property var settings: parent.settings

    Component.onCompleted: {
        // Configure window layer shell
        Layering.LayeringControl.configureWindow(mainWindow, settings)

        // Build app UI
        App.App.buildApp(mainWindow, state)
    }

    // Main window content
    contentItem: Rectangle {
        color: "transparent"

        Layout.fillWidth: settings.position === "top" || settings.position === "bottom"
        Layout.fillHeight: settings.position === "left" || settings.position === "right"

        App.App {
            id: appContainer
        }
    }

    Connections {
        target: state
        function onItemsChanged() {
            appContainer.refresh()
        }
    }
}
