import Quickshell
import "modules"

ShellRoot {
    Variants {
        model: Quickshell.screens
        delegate: Dock {
            required property var modelData
            screen: modelData
        }
    }
}
