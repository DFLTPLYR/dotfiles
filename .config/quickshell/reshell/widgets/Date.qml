import QtQml
import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.core
import qs.types

Wrapper {
    id: wrap

    width: wrap.setWidth(property.size)
    height: wrap.setHeight(property.size)

    GridLayout {
        anchors.fill: parent

        QtObject {
            id: date

            property var locale: Qt.locale()
            property date currentDate: new Date()
        }

        Text {
            text: date.currentDate.toLocaleDateString(date.locale, "MMMM d")
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Colors.color.primary
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            font {
                pixelSize: property.fontSize
            }

        }

    }

    property: Property {
        property int size: 40
        property int fontSize: 10
    }

}
