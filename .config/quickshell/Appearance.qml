// Appearance.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland

PersistentProperties {
    id: persist
    reloadableId: "testSettings"

    property int fontsize: 12
    property bool isOpen: false
}
