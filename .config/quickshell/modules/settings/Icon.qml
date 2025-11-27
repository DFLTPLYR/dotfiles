import QtQuick

Rectangle {
    id: icon
    required property Item dragParent

    property int visualIndex: 0
    width: 72
    height: 72
    anchors {
        horizontalCenter: parent.horizontalCenter
        verticalCenter: parent.verticalCenter
    }
    radius: 3

    Text {
        anchors.centerIn: parent
        color: "white"
        text: parent.visualIndex
    }

    DragHandler {
        id: dragHandler
    }

    Drag.active: dragHandler.active
    Drag.source: icon
    Drag.hotSpot.x: 36
    Drag.hotSpot.y: 36

    states: [
        State {
            when: dragHandler.active
            ParentChange {
                target: icon
                parent: icon.dragParent
            }

            AnchorChanges {
                target: icon
                anchors {
                    horizontalCenter: undefined
                    verticalCenter: undefined
                }
            }
        }
    ]
}
