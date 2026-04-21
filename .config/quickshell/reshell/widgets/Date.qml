import QtQuick
import QtQuick.Layouts
import Quickshell
import QtQml

import qs.core
import qs.components
import qs.types

Wrapper {
    id: wrap

    property: Property {
        property int size: 40
        property int fontSize: 10
    }

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
            font {
                pixelSize: property.fontSize
            }
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}
