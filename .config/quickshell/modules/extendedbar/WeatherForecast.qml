import QtQuick
import QtQuick.Layouts

import qs.services
import qs.assets

RowLayout {
    anchors.fill: parent

    Repeater {
        model: WeatherFetcher.weatherForecast ?? []

        delegate: Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"
            Layout.alignment: Qt.AlignVCenter

            Column {
                anchors.centerIn: parent
                spacing: 2

                Text {
                    text: Qt.formatDate(modelData.date, "ddd, MMM yyyy")
                    color: Assets.color10
                    font.family: FontAssets.fontAwesomeRegular
                }

                Text {
                    text: modelData.avgTemp
                    color: Assets.color10
                    font.family: FontAssets.fontAwesomeRegular
                }

                Text {
                    text: modelData.icon
                    color: Assets.color10
                    font.family: FontAssets.fontAwesomeSolid
                }

                Text {
                    text: modelData.desc
                    color: Assets.color10
                    font.family: FontAssets.fontAwesomeRegular
                }
            }
        }
    }
}
