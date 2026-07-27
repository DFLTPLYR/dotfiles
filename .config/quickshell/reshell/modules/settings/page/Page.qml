pragma ComponentBehavior: Bound
import qs.components
import Quickshell
import QtQuick
import QtQuick.Layouts

Item {
    id: pane
    default property alias content: container.data
    property alias grid: gridContainer
    Layout.fillWidth: true
    Layout.fillHeight: true
    visible: ListView.isCurrentItem

    Column {
        id: gridContainer
        z: 10
        anchors {
            right: pane.right
            bottom: parent.bottom
            rightMargin: 10
            bottomMargin: 10
        }
    }

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
