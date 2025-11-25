import QtQuick
import Quickshell

import qs.config
import qs.utils
import qs.assets
import qs.services

Item {
    Component {
        id: portrait
        Column {
            anchors.centerIn: parent
            spacing: 4
            width: parent.width    // give it size
            height: parent.height  // give it size

            Text {
                color: Color.color14
                font.family: FontProvider.fontMaterialRounded
                text: TimeService.hoursPadded
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                width: parent.width
                height: parent.height * 0.4

                font.bold: true
                font.pixelSize: Math.max(10, Math.min(width, height) * 0.2)
            }

            Text {
                color: Color.color14
                font.family: FontProvider.fontMaterialRounded
                text: TimeService.minutesPadded
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                width: parent.width
                height: parent.height * 0.4

                font.bold: true
                font.pixelSize: Math.max(10, Math.min(width, height) * 0.2)
            }
        }
    }

    Component {
        id: landscape
        Text {
            anchors {
                verticalCenter: parent.verticalCenter
                horizontalCenter: parent.horizontalCenter
            }

            color: Color.color14
            font.family: FontProvider.fontMaterialRounded
            text: `${TimeService.hoursPadded}:${TimeService.minutesPadded}... ${TimeService.ampm}`
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            width: parent.width
            font.bold: true
            font.pixelSize: {
                var minSize = 10;
                return Math.max(minSize, Math.min(parent.height, parent.width) * 0.2);
            }
        }
    }

    Loader {
        anchors.fill: parent
        sourceComponent: Config.navbar.side ? portrait : landscape
    }
}
