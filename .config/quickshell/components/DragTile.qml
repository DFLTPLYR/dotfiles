import QtQuick

//! [0]
Item {
    id: root

    required property string colorKey
    required property int modelData
    property int row: 1
    property int column: 1

    width: 64 * row
    height: 64 * column
    MouseArea {
        id: mouseArea

        width: root.width
        height: root.height
        anchors.centerIn: parent

        drag.target: tile

        onReleased: {
            parent = tile.Drag.target !== null ? tile.Drag.target : root;
        }

        acceptedButtons: Qt.LeftButton | Qt.RightButton

        Rectangle {
            id: tile

            width: parent.width
            height: parent.height

            anchors {
                verticalCenter: parent.verticalCenter
                horizontalCenter: parent.horizontalCenter
            }

            color: root.colorKey

            Drag.keys: [root.colorKey, root.row, root.column]
            Drag.active: mouseArea.drag.active

            Drag.hotSpot.x: parent.width / 4
            Drag.hotSpot.y: parent.height / 4

            Text {
                anchors.fill: parent
                color: "white"
                font.pixelSize: 48
                text: root.modelData + 1
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            states: State {
                when: mouseArea.drag.active
                AnchorChanges {
                    target: tile
                    anchors {
                        verticalCenter: undefined
                        horizontalCenter: undefined
                    }
                }
            }
        }
    }
}
