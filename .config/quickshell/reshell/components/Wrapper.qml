import Quickshell
import QtQuick
import qs.core

Item {
    id: container
    property int widgetIndex: -1
    property var innerGridRef: null
    signal drop(int mouseX, int mouseY)

    Drag.active: ma.drag.active

    MouseArea {
        id: ma
        enabled: Global.widget
        anchors.fill: parent
        propagateComposedEvents: true
        drag.target: container
        onReleased: {
            container.Drag.drop();
            container.drop(mouseX, mouseY);
        }
    }
}
