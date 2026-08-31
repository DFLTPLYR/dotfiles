import QtQuick
import qs.components
import qs.types
import qs.core

WidgetWrap {
    id: wrap
    anchors.fill: parent

    property: Property {
        property int icon: 12
        property int width: 100
        property int test: 100
    }

    Rectangle {
        width: parent.width / 2
        height: parent.width / 2
        radius: width / 2
        x: (parent.width / 2) - (width / 2)
        y: (parent.height / 2) - (height / 2)

        Text {
            anchors.centerIn: parent
            text: property.test
        }

        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: true
            onClicked: {
                print(Global.fonts);
            }
        }
    }
}
