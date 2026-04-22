import QtQuick
import "../../pkg/ipc" as IPC
import "../../internal/itemsctl" as ItemsCtl
import "../../internal/pvctl" as PVCtl

QtObject {
    id: state

    // State properties
    property var settings: null
    property var logger: null
    property var window: null
    property var layerctl: null
    property var itemsBox: null
    property var list: null
    property var pv: null
    property var pinned: []

    // Signals
    signal itemsChanged()
    signal windowsUpdated()
    signal settingsLoaded()

    // Initialize state with settings
    function init(settings) {
        state.settings = settings
        state.logger = createLogger()
        state.list = ItemsCtl.ItemsList.create()
        state.pv = PVCtl.PVControl.create(settings, state.logger)
        state.pinned = settings.pinnedApps || []
        state.settingsLoaded()
    }

    // Getters
    function getSettings() {
        return state.settings
    }

    function getLogger() {
        return state.logger
    }

    function getWindow() {
        return state.window
    }

    function getLayerctl() {
        return state.layerctl
    }

    function getItemsBox() {
        return state.itemsBox
    }

    function getList() {
        return state.list
    }

    function getPV() {
        return state.pv
    }

    function getPinned() {
        return state.pinned
    }

    // Setters
    function setWindow(window) {
        state.window = window
    }

    function setLayerctl(layerctl) {
        state.layerctl = layerctl
    }

    function setItemsBox(itemsBox) {
        state.itemsBox = itemsBox
    }

    function setPinned(pinned) {
        state.pinned = pinned
        state.itemsChanged()
    }

    // Utilities
    function createLogger() {
        return {
            debug: function(msg) { console.log("[DEBUG]", msg) },
            info: function(msg) { console.log("[INFO]", msg) },
            warn: function(msg) { console.warn("[WARN]", msg) },
            error: function(msg) { console.error("[ERROR]", msg) }
        }
    }

    // Update items from IPC
    function updateItems() {
        IPC.IPC.getClients(function(clients) {
            // Refresh items based on clients
            state.itemsChanged()
        })
    }
}
