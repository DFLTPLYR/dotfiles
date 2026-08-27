import QtQuick
import qs.components
import qs.types

Wrapper {
    id: wrap

    width: wrap.setSize()
    height: wrap.setSize()

    property: Property {
        property int icon: 12
        property int width: 100
        property int test: 100
    }

    Rectangle {
        width: parent.width / 2
        height: parent.width / 2
        radius: width / 2
        Text {
            anchors.centerIn: parent
            text: property.test
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                print("test");
            }
        }
    }
}
