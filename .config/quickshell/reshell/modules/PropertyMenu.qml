import QtQuick
import Quickshell
import qs.core
import qs.components

FloatingWindow {
    id: propertiesModal

    title: "Reshell"
    color: "transparent"

    visible: Compositor.focusedWindow === screen.name && Global.edit

    minimumSize: Qt.size(screen.width / 1.5, screen.height / 1.5)
    maximumSize: Qt.size(screen.width / 1.5, screen.height / 1.5)

    LazyLoader {
        active: propertiesModal.visible
        component: Rectangle {
            color: Colors.color.background

            width: screen.width / 1.5
            height: screen.height / 1.5

            border {
                width: 1
                color: Colors.color.primary
            }

            Component.onCompleted: {
                Global.bindRadii(this);
                Global.properties = true;
            }
            Component.onDestruction: Global.properties = false
        }
    }
}
