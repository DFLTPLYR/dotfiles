import Quickshell
import QtQuick
import qs.core

Item {
    id: container
    Drag.active: ma.Drag.active

    MouseArea {
        id: ma
        enabled: Global.widget
        anchors.fill: parent
        propagateComposedEvents: true
        drag.target: container
        onReleased: {
            container.Drag.drop();
        }
    }
}
