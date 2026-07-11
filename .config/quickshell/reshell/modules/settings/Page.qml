pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

Item {
    id: pane
    default property alias content: container.data

    Flickable {
        anchors.fill: parent
        interactive: true
        contentWidth: container.width
        contentHeight: container.implicitHeight
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: container
            width: pane.width
        }
    }
}
