import QtQuick
import QtQuick.Layouts

import qs.core
import qs.types
import qs.components

Wrapper {
    id: wrap
    property: Property {
        property int size: 120
    }

    width: wrap.setWidth(property.size)
    height: wrap.setHeight(property.size)
    GridLayout {
        anchors.fill: parent
        columns: wrap.side ? 1 : 2
        rows: wrap.side ? 2 : 1

        Icon {
            text: "gaming-pad-alt"
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Colors.color.primary
            font.pixelSize: Math.min(width, height)
            fontSizeMode: Text.Fit
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            text: `${Hardware.gpuUsagePercent.toFixed(0)} %`
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Colors.color.primary
            font {
                pixelSize: Math.min(wrap.width, wrap.height) / 2
            }
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}
