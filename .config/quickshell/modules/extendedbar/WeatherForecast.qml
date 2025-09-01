import QtQuick
import QtQuick.Layouts

import qs.utils
import qs.assets
import qs.services
import qs.components

ColumnLayout {
    id: weatherPanel
    anchors.fill: parent
    property bool isLoading: true
    // Weather Forecast
    Item {
        Layout.preferredHeight: Math.round(parent.height * 0.7)
        Layout.fillWidth: true

        RowLayout {
            anchors.fill: parent
            spacing: 4

            Rectangle {
                id: currentCondition
                Layout.fillHeight: true
                Layout.preferredWidth: Math.round(parent.width * 0.4)
                color: Scripts.setOpacity(Assets.color0, 0.5)
                radius: 4

                // loading
                Component {
                    id: loadingContent
                    ColumnLayout {
                        anchors.fill: parent

                        Item {
                            Layout.fillHeight: true
                            Layout.alignment: Qt.AlignCenter
                            Text {
                                anchors.bottom: parent.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: 'Loading...'
                                font.pixelSize: 12
                                color: Assets.color10
                            }
                        }

                        Item {
                            Layout.alignment: Qt.AlignCenter
                            Layout.fillHeight: true
                            Text {
                                text: "\ue86a"
                                color: Assets.color10
                                font.pixelSize: 12
                                font.family: FontAssets.fontMaterialRounded
                                RotationAnimation on rotation {
                                    from: 0
                                    to: 360
                                    duration: 3000
                                    loops: Animation.Infinite
                                    running: weatherPanel.isLoading
                                }
                            }
                        }
                    }
                }

                // loaded
                Component {
                    id: loadedContent
                    ColumnLayout {
                        anchors.fill: parent

                        Item {
                            Layout.preferredHeight: parent.height * 0.5
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignCenter

                            Rectangle {
                                anchors.bottom: parent.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                height: parent.height * 0.7
                                width: height
                                radius: height / 2
                                color: Scripts.setOpacity(Assets.background, 0.8)

                                Text {
                                    anchors.centerIn: parent
                                    text: WeatherFetcher.currentCondition?.icon ?? ""
                                    color: Assets.color10
                                    font.bold: true
                                    font.family: FontAssets.fontMaterialRounded
                                    font.pixelSize: Math.min(parent.height, parent.width)
                                }
                            }
                        }

                        Text {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignBottom
                            Layout.alignment: Qt.AlignCenter
                            text: WeatherFetcher.currentCondition?.temp ?? ""
                            color: Assets.color10
                            wrapMode: Text.Wrap
                        }
                        Text {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignCenter
                            horizontalAlignment: Text.AlignHCenter
                            text: WeatherFetcher.currentCondition?.weatherDesc ?? ""
                            color: Assets.color10
                            wrapMode: Text.Wrap
                        }
                        Text {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            Layout.alignment: Qt.AlignCenter
                            text: WeatherFetcher.currentCondition?.feelslike ?? ""
                            color: Assets.color10
                            wrapMode: Text.Wrap
                        }
                    }
                }
                Loader {
                    anchors.fill: parent
                    sourceComponent: weatherPanel.isLoading ? loadingContent : loadedContent
                }
            }

            Component {
                id: loadingRepeater
                RowLayout {
                    anchors.fill: parent
                    spacing: 4
                    Repeater {
                        model: [0, 1, 2]
                        delegate: Rectangle {
                            id: loadingDelegate
                            required property var modelData
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            color: Scripts.setOpacity(Assets.color0, 0.5)
                            radius: 4
                            ColumnLayout {
                                anchors.fill: parent

                                Item {
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignCenter
                                    Text {
                                        anchors.bottom: parent.bottom
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: 'Loading...'
                                        font.pixelSize: 12
                                        color: Assets.color10
                                    }
                                }

                                Item {
                                    Layout.alignment: Qt.AlignCenter
                                    Layout.fillHeight: true
                                    Text {
                                        text: "\ue86a"
                                        color: Assets.color10
                                        font.pixelSize: 12
                                        font.family: FontAssets.fontMaterialRounded
                                        RotationAnimation on rotation {
                                            from: 0
                                            to: 360
                                            duration: 3000
                                            loops: Animation.Infinite
                                            running: isLoading
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Component {
                id: loadedRepeater
                RowLayout {
                    anchors.fill: parent
                    spacing: 4
                    Repeater {
                        model: WeatherFetcher.weatherForecast
                        delegate: Rectangle {
                            required property var modelData
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            color: Scripts.setOpacity(Assets.color0, 0.5)
                            radius: 4

                            ColumnLayout {
                                anchors.fill: parent

                                Text {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    text: {
                                        const today = new Date();
                                        today.setHours(0, 0, 0, 0);
                                        const forecastDate = new Date(modelData?.date);
                                        forecastDate.setHours(0, 0, 0, 0);
                                        const diffDays = Math.floor((forecastDate - today) / (1000 * 60 * 60 * 24));
                                        switch (diffDays) {
                                        case 0:
                                            return "Today";
                                        case 1:
                                            return "Tomorrow";
                                        case 2:
                                            return "Day After";
                                        default:
                                            return Qt.formatDate(modelData?.date ?? new Date(), "ddd, MMM yyyy");
                                        }
                                    }
                                    color: Assets.color10
                                }
                                Rectangle {
                                    Layout.preferredHeight: parent.height * 0.3
                                    Layout.preferredWidth: parent.height * 0.3
                                    Layout.alignment: Qt.AlignCenter
                                    radius: height / 2
                                    color: Scripts.setOpacity(Assets.background, 0.8)
                                    Text {
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        anchors.fill: parent
                                        text: modelData?.icon
                                        color: Assets.color10
                                        font.family: FontAssets.fontMaterialRounded
                                        font.pixelSize: Math.round(parent.height * 0.8)
                                    }
                                }
                                Text {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    text: modelData?.avgTemp
                                    color: Assets.color10
                                }
                                Text {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    text: modelData?.desc
                                    color: Assets.color10
                                    wrapMode: Text.Wrap
                                }
                            }
                        }
                    }
                }
            }

            Loader {
                Layout.fillHeight: true
                Layout.fillWidth: true
                sourceComponent: weatherPanel.isLoading ? loadingRepeater : loadedRepeater
            }
        }
    }
    // Other details
    Item {
        Layout.fillHeight: true
        Layout.fillWidth: true

        RowLayout {
            anchors.fill: parent
            spacing: 4

            Component {
                id: weatherDetailComponent
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: Scripts.setOpacity(Assets.color0, 0.5)
                    radius: 4

                    property string iconText: ""
                    property string titleText: ""
                    property string valueText: ""

                    ColumnLayout {
                        anchors.fill: parent

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Rectangle {
                                width: 24
                                height: 24
                                Layout.alignment: Qt.AlignCenter
                                radius: height / 2
                                color: "transparent"
                                Text {
                                    anchors.centerIn: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    text: iconText
                                    color: Assets.color10
                                    font.family: FontAssets.fontMaterialRounded
                                    font.pixelSize: Math.min(parent.height, parent.width) * 0.8
                                }
                            }
                            Text {
                                width: 40
                                text: titleText
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                color: Assets.color10
                                font.family: FontAssets.fontSometypeMono
                                font.pixelSize: Math.min(parent.height, parent.width) * 0.5
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Text {
                                anchors.fill: parent
                                anchors.margins: 10
                                text: valueText
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                color: Assets.color10
                            }
                        }
                    }
                }
            }

            // Humidity
            Loader {
                Layout.fillHeight: true
                Layout.fillWidth: true
                sourceComponent: weatherDetailComponent
                onLoaded: {
                    item.iconText = "\ue798";
                    item.titleText = qsTr("Humidity");
                    item.valueText = WeatherFetcher.currentCondition?.humidity ?? "";
                }
            }
            // Windspeed
            Loader {
                Layout.fillHeight: true
                Layout.fillWidth: true
                sourceComponent: weatherDetailComponent
                onLoaded: {
                    item.iconText = "\uefd8";
                    item.titleText = qsTr("Windspeed");
                    item.valueText = WeatherFetcher.currentCondition?.windSpeed ?? "";
                }
            }
            // Visibility
            Loader {
                Layout.fillHeight: true
                Layout.fillWidth: true
                sourceComponent: weatherDetailComponent
                onLoaded: {
                    item.iconText = "\ue8f4";
                    item.titleText = qsTr("Visibility");
                    item.valueText = WeatherFetcher.currentCondition?.visibility ?? "";
                }
            }
            // Pressure
            Loader {
                Layout.fillHeight: true
                Layout.fillWidth: true
                sourceComponent: weatherDetailComponent
                onLoaded: {
                    item.iconText = "\uf6bb";
                    item.titleText = qsTr("Pressure");
                    item.valueText = WeatherFetcher.currentCondition?.pressure ?? "";
                }
            }
        }
    }

    Connections {
        target: WeatherFetcher
        function onParseDone() {
            weatherPanel.isLoading = false;
        }
    }

    Component.onCompleted: {
        weatherPanel.isLoading = typeof WeatherFetcher.currentCondition === 'undefined';
    }
}
