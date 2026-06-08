import QtQuick
import QtQuick.Layouts
import qs.components
import qs.core
import qs.types

Wrapper {
    id: wrap

    width: wrap.setWidth(property.size)
    height: wrap.setHeight(property.size)

    property: Property {
        property int size: 40
        property int fontSize: 10
        property string format: "hh:mm AP"
    }

    GridLayout {
        anchors.fill: parent

        Text {
            text: Qt.formatDateTime(Global.clock.date, wrap.property.format)
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Colors.theme.primary
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            font {
                pixelSize: property.fontSize
            }
        }
    }
}
