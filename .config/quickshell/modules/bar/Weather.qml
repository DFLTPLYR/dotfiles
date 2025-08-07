// ClockWidget.qml
import QtQuick
import Quickshell
import Quickshell.Io

import qs.services
import qs.animations
import qs.assets
import qs.modules

Item {
    id: root
    implicitWidth: weatherText.implicitWidth
    height: parent.height

    Text {
        id: weatherText
        visible: true
        text: WeatherFetcher.weatherInfo
        color: Colors.color10

        font.pixelSize: Appearance.fontsize
        font.family: "monospace"
        Fade on text {}

        anchors.verticalCenter: parent.verticalCenter
    }
}
