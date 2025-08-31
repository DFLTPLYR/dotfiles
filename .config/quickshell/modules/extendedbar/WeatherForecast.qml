import QtQuick
import QtQuick.Layouts

import qs.utils
import qs.assets
import qs.services
import qs.components

ColumnLayout {
    id: weatherPanel
    anchors.fill: parent

    // Weather Forecast
    Item {
        Layout.preferredHeight: Math.round(parent.height * 0.7)
        Layout.fillWidth: true

        RowLayout {
            anchors.fill: parent
            spacing: 4

            anchors {
                topMargin: 10
                rightMargin: 10
                leftMargin: 10
            }
            Rectangle {
                id: currentCondition
                property bool isLoading: typeof WeatherFetcher.currentCondition === undefined
                Layout.preferredWidth: Math.round(parent.width * 0.4)
                Layout.fillHeight: true
                color: Scripts.setOpacity(Assets.color0, 0.5)
                radius: 4

                // loading
                ColumnLayout {
                    visible: currentCondition.isLoading
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
                                running: currentCondition.isLoading
                            }
                        }
                    }
                }

                // loaded
                ColumnLayout {
                    visible: !currentCondition.isLoading
                    anchors.fill: parent
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
                            text: 'loading'
                            color: Assets.color10
                            font.family: FontAssets.fontMaterialRounded
                            font.pixelSize: Math.round(parent.height * 0.8)
                        }
                    }
                    Text {
                        Layout.fillHeight: true
                        verticalAlignment: Text.AlignBottom
                        Layout.alignment: Qt.AlignCenter
                        text: 'loading'
                        color: Assets.color10
                    }
                    Text {
                        Layout.alignment: Qt.AlignCenter
                        text: "test2"
                        color: Assets.color10
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.alignment: Qt.AlignCenter
                        text: "test3"
                        color: Assets.color10
                    }
                }
            }

            Repeater {
                model: (WeatherFetcher.weatherForecast && WeatherFetcher.weatherForecast.length > 0) ? WeatherFetcher.weatherForecast : [0, 1, 2]
                delegate: Rectangle {
                    required property var modelData
                    property bool isLoading: typeof modelData === "number"
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: Scripts.setOpacity(Assets.color0, 0.5)
                    radius: 4

                    // loading
                    ColumnLayout {
                        visible: isLoading
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

                    // loaded
                    ColumnLayout {
                        visible: !isLoading
                        anchors.fill: parent

                        Text {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: {
                                const today = new Date();
                                const forecastDate = new Date(modelData.date);
                                const diffDays = Math.floor((forecastDate - today) / (1000 * 60 * 60 * 24));
                                switch (diffDays) {
                                case 0:
                                    return "Today";
                                case 1:
                                    return "Tomorrow";
                                case 2:
                                    return "Day After";
                                default:
                                    return Qt.formatDate(modelData.date, "ddd, MMM yyyy");
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
                                text: modelData.icon ? modelData?.icon : 'loading'
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
                            text: modelData.avgTemp ? modelData?.avgTemp : "Loading..."
                            color: Assets.color10
                        }
                        Text {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: modelData?.desc ? modelData.desc : "loading"
                            color: Assets.color10
                            wrapMode: Text.Wrap
                        }
                    }
                }
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
            anchors {
                bottomMargin: 10
                rightMargin: 10
                leftMargin: 10
            }

            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true
                color: Scripts.setOpacity(Assets.color0, 0.5)
                radius: 4
            }
            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true
                color: Scripts.setOpacity(Assets.color0, 0.5)
                radius: 4
            }
            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true
                color: Scripts.setOpacity(Assets.color0, 0.5)
                radius: 4
            }
            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true
                color: Scripts.setOpacity(Assets.color0, 0.5)
                radius: 4
            }
        }
    }
}
