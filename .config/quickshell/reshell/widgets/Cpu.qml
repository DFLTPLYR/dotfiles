import QtQuick
import QtQuick.Layouts

import qs.core
import qs.types
import qs.components

Wrapper {
    id: wrap

    property: Property {
        property int size: 120
        property int icon: 10
        property int text: 10
    }

    width: wrap.setWidth(property.size)
    height: wrap.setHeight(property.size)

    GridLayout {
        anchors.fill: parent
        columns: wrap.slotConfig ? (wrap.slotConfig.side ? 1 : 2) : 2
        rows: wrap.slotConfig ? (wrap.slotConfig.side ? 2 : 1) : 1

        Icon {
            text: "circuit"
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Colors.color.primary
            font.pixelSize: Math.min(width, height)
            fontSizeMode: Text.Fit
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            text: `${Hardware.cpuUsagePercent.toFixed(0)} %`
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Colors.color.primary
            font.pixelSize: property.text
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}
