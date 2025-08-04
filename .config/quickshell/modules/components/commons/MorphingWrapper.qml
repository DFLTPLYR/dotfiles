import QtQuick

Item {
    id: wrapper
    property alias contentItem: container.data
    property bool expanded: false
    property real collapsedWidth: 50
    property real collapsedHeight: 50
    property real expandedWidth: 300
    property real expandedHeight: 200

    width: animatedBox.width
    height: animatedBox.height

    Rectangle {
        id: animatedBox
        width: expanded ? expandedWidth : collapsedWidth
        height: expanded ? expandedHeight : collapsedHeight
        radius: expanded ? 12 : width / 2
        color: "lightgray"
        scale: expanded ? 1.0 : 0.1
        anchors.centerIn: parent
        clip: true
        transformOrigin: Item.Center

        Behavior on width {
            NumberAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }
        Behavior on radius {
            NumberAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }
        Behavior on scale {
            NumberAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }

        Item {
            id: container
            anchors.fill: parent
        }
    }
}
