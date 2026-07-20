pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts

Item {
    id: pane
    default property alias content: container.data
    Layout.fillWidth: true
    Layout.fillHeight: true
    visible: ListView.isCurrentItem

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
