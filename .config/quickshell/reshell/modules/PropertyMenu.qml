import QtQuick
import Quickshell
import qs.core
import qs.components

FloatingWindow {
    id: propertiesModal

    title: "Reshell"
    color: Colors.setOpacity(Colors.color.background, 0.5)

    visible: Compositor.focusedWindow === screen.name && Global.edit

    minimumSize: Qt.size(screen.width / 1.5, screen.height / 1.5)
    maximumSize: Qt.size(screen.width / 1.5, screen.height / 1.5)
}
