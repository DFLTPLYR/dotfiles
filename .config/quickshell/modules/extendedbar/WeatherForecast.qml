import QtQuick
import QtQuick.Layouts

import qs.utils
import qs.assets
import qs.services
import qs.components

ColumnLayout {
    id: weatherPanel
    anchors.fill: parent

    Item {
        Layout.preferredHeight: Math.round(parent.height * 0.7)
        Layout.fillWidth: true
        RowLayout {
            anchors.fill: parent
            spacing: 4
            anchors.margins: 4

            Item {
                Layout.fillHeight: true
                Layout.preferredWidth: Math.round(parent.width * 0.4)
            }

            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
        }
    }

    Item {
        Layout.fillHeight: true
        Layout.fillWidth: true

        RowLayout {
            anchors.fill: parent
            spacing: 2
            anchors {
                bottomMargin: 4
                rightMargin: 4
                leftMargin: 4
            }

            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
        }
    }
}
// Repeater {
//     model: WeatherFetcher.weatherForecast ?? []

//     delegate: Rectangle {
//         Layout.fillWidth: true
//         Layout.fillHeight: true
//         color: "transparent"
//         Layout.alignment: Qt.AlignVCenter

//         Column {
//             anchors.centerIn: parent
//             spacing: 2

//             Text {
//                 text: Qt.formatDate(modelData.date, "ddd, MMM yyyy")
//                 color: Assets.color10
//                 font.family: FontAssets.fontAwesomeRegular
//             }

//             Text {
//                 text: modelData.avgTemp
//                 color: Assets.color10
//                 font.family: FontAssets.fontAwesomeRegular
//             }

//             Text {
//                 text: modelData.icon
//                 color: Assets.color10
//                 font.family: FontAssets.fontAwesomeSolid
//             }

//             Text {
//                 text: modelData.desc
//                 color: Assets.color10
//                 font.family: FontAssets.fontAwesomeRegular
//             }
//         }
//     }
// }

