import QtQuick

QtObject {
    id: btnctl

    property var previewControl: null
    property var defaultControl: null

    // Dispatch button click based on mode
    function dispatch(button, mode, state) {
        if (mode === "preview") {
            handlePreview(button, state)
        } else {
            handleDefault(button, state)
        }
    }

    function handlePreview(button, state) {
        // Show window preview/thumbnails
        if (previewControl) {
            previewControl.showPreview(button)
        }
    }

    function handleDefault(button, state) {
        // Route to default control handler
        if (defaultControl) {
            defaultControl.control(button, state)
        }
    }
}
