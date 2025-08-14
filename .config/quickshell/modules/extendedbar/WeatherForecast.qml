import QtQuick
import QtQuick.Layouts

import qs.services

RowLayout {
    anchors.fill: parent

    Repeater {
        model: [...WeatherFetcher.weatherForecast]

        delegate: Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"
            Layout.alignment: Qt.AlignVCenter

            Column {
                anchors.centerIn: parent
                spacing: 2

                Text {
                    text: modelData.date
                    color: Colors.color10
                }
                Text {
                    text: modelData.avgTemp
                    color: Colors.color10
                }
                Text {
                    text: modelData.desc
                    color: Colors.color10
                }
                Text {
                    text: modelData.icon
                    color: Colors.color10
                }
            }
        }
    }

    Component.onCompleted: console.log(WeatherFetcher.weatherForecast)
}
