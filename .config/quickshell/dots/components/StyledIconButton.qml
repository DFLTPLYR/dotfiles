import QtQuick
import QtQuick.Controls

Button {
    id: root
    property alias iconSource: iconImage.source
    property alias iconRounding: background.radius
    property int iconMargin: 0
    property alias backgroundColor: background.color
    hoverEnabled: true

    background: Rectangle {
        id: background
        color: root.hovered ? Qt.rgba(255, 255, 255, 0.1) : "transparent"
        radius: 8
        anchors.fill: iconImage
        Behavior on color {
            ColorAnimation {
                duration: 200
            }
        }
    }
    contentItem: Image {
        id: iconImage
        fillMode: Image.PreserveAspectFit
        anchors {
            fill: parent
            margins: root.iconMargin
        }
    }
}
