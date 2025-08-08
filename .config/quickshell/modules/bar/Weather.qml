// ClockWidget.qml
import QtQuick
import Quickshell
import Quickshell.Io

import qs
import qs.assets
import qs.modules
import qs.services
import qs.animations

Item {
    id: root
    implicitWidth: weatherText.implicitWidth
    height: parent.height

    Text {
        id: weatherText
        visible: true
        text: WeatherFetcher.weatherInfo ? `${WeatherFetcher.weatherInfo} - ${WeatherFetcher.weatherCondition}` : ''
        color: Colors.color10

        font.pixelSize: Appearance.fontsize
        font.family: FontAssets.fontAwesomeRegular
        Fade on text {}

        anchors.verticalCenter: parent.verticalCenter
    }
}
