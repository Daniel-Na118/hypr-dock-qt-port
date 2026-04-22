import QtQuick

QtObject {
    id: itemsList

    // Thread-safe map of items by className
    property var items: ({})
    property int count: 0

    function create() {
        return Qt.createQmlObject("
            import QtQuick
            import 'ItemsList.qml' as ItemsList
            ItemsList.ItemsList {}
        ", itemsList)
    }

    function get(className) {
        return items[className] || null
    }

    function add(className, item) {
        if (!items[className]) {
            items[className] = item
            count++
            return true
        }
        return false
    }

    function remove(className) {
        if (items[className]) {
            delete items[className]
            count--
            return true
        }
        return false
    }

    function len() {
        return count
    }

    function getAll() {
        var result = []
        for (var className in items) {
            if (items.hasOwnProperty(className)) {
                result.push(items[className])
            }
        }
        return result
    }

    function searchWindow(windowAddress) {
        for (var className in items) {
            if (items.hasOwnProperty(className)) {
                var item = items[className]
                if (item.windows && item.windows[windowAddress]) {
                    return item
                }
            }
        }
        return null
    }

    function clear() {
        items = {}
        count = 0
    }

    // Iterator support
    function forEach(callback) {
        for (var className in items) {
            if (items.hasOwnProperty(className)) {
                callback(className, items[className])
            }
        }
    }
}
