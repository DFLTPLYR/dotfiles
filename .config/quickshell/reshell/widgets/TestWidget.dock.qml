import QtQuick
import qs.types

Rectangle {
    id: widget
    property Property property: Property {
        property int num: 12
        property int width: 100
    }

    width: parent.width / 2
    height: parent.width / 2
    radius: width / 2

    x: (parent.width / 2) - (width / 2)
    y: (parent.height / 2) - (height / 2)

    Text {
        anchors.centerIn: parent
        text: widget.property.num
    }
}
