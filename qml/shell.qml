import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire

import qs.assets

import Qt5Compat.GraphicalEffects

ShellRoot {
    Variants {
        model: Quickshell.screens
        delegate: FloatingWindow {
            required property var modelData
            maximumSize: Qt.size(modelData.width / 2, modelData.height / 2)
            minimumSize: Qt.size(modelData.width / 2, modelData.height / 2)
            color: "transparent"

            Rectangle {
                id: root
                readonly property ColorGroup colors: Window.active ? palette.active : palette.inactive
                anchors.fill: parent
                color: colors.window
                property bool isPortrait: height > width

                Item {
                    width: Math.max(200, root.width / 6)
                    height: root.height / 4

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 10
                        radius: 8
                        layer.enabled: true
                        layer.smooth: true

                        gradient: Gradient {
                            GradientStop {
                                position: 0.0
                                color: Qt.rgba(1, 1, 1, 0.06)
                            }
                            GradientStop {
                                position: 1.0
                                color: Qt.rgba(1, 1, 1, 0.02)
                            }
                        }

                        border.color: Qt.rgba(1, 1, 1, 0.08)

                        Component {
                            id: landscape
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10

                                Item {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    RoundButton {
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        font.pixelSize: width
                                        text: currentCondition.icon
                                        font.family: FontProvider.fontMaterialOutlined
                                        background: Rectangle {
                                            anchors.fill: parent
                                            color: "transparent"
                                        }
                                    }
                                }
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                }
                            }
                        }

                        Component {
                            id: portrait
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 10

                                Item {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    RoundButton {
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        font.pixelSize: height
                                        text: currentCondition.icon
                                        font.family: FontProvider.fontMaterialOutlined
                                        background: Rectangle {
                                            anchors.fill: parent
                                            color: "transparent"
                                        }
                                    }
                                }
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                }
                            }
                        }

                        Loader {
                            anchors.fill: parent
                            sourceComponent: root.isPortrait ? portrait : landscape
                        }
                    }
                }

                // Label {
                //     id: clock
                //     property var date: new Date()

                //     anchors {
                //         horizontalCenter: parent.horizontalCenter
                //         top: parent.top
                //         topMargin: 100
                //     }

                //     renderType: Text.NativeRendering
                //     font.pointSize: 80

                //     // updates the clock every second
                //     Timer {
                //         running: true
                //         repeat: true
                //         interval: 1000

                //         onTriggered: clock.date = new Date()
                //     }

                //     // updated when the date changes
                //     text: {
                //         const hours = this.date.getHours().toString().padStart(2, '0');
                //         const minutes = this.date.getMinutes().toString().padStart(2, '0');
                //         return `${hours}:${minutes}`;
                //     }
                // }

                // ColumnLayout {
                //     anchors {
                //         horizontalCenter: parent.horizontalCenter
                //         top: parent.verticalCenter
                //     }

                //     RowLayout {
                //         TextField {
                //             id: passwordBox

                //             implicitWidth: 400
                //             padding: 10

                //             focus: true
                //             echoMode: TextInput.Password
                //             inputMethodHints: Qt.ImhSensitiveData

                //             // Update the text in the context when the text in the box changes.
                //             onTextChanged: {}

                //             // Try to unlock when enter is pressed.
                //             onAccepted: {}
                //         }

                //         Button {
                //             text: "Unlock"
                //             padding: 10

                //             // don't steal focus from the text box
                //             focusPolicy: Qt.NoFocus
                //         }
                //     }

                //     Label {
                //         visible: true
                //         text: "Incorrect password"
                //     }
                // }
            }
        }
    }

    function fetchWeather() {
        const xhr = new XMLHttpRequest();
        const url = "http://localhost:6969/weather";
        xhr.open("GET", url);
        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        const json = JSON.parse(xhr.responseText);
                        parseWeather(json);
                    } catch (e) {
                        console.warn("Failed to parse weather JSON:", e);
                    }
                } else {
                    console.warn("Failed to fetch weather data:", xhr.statusText);
                }
            }
        };
        xhr.send();
    }

    function parseWeather(json) {
        weatherData = json || {};

        const current = json.current;
        currentCondition = {
            weatherDesc: current.condition.text,
            feelslike: `Feels like ${current.feelslike_c}°C`,
            temp: `${current.temp_c}°C`,
            icon: getIconFromCode(current.condition.code),
            visibility: current.vis_km,
            pressure: current.pressure_mb,
            humidity: current.humidity,
            windSpeed: current.wind_kph
        };

        const forecastArr = json.forecast.forecastday || [];
        const now = new Date();

        for (let i = 0; i < Math.min(forecastArr.length, 3); i++) {
            const day = forecastArr[i];
            const noonHour = day.hour[12]; // 12:00 noon
            const code = noonHour ? noonHour.condition.code : day.day.condition.code;
            const iconChar = getIconFromCode(code);

            const forecastDate = new Date(day.date + " 12:00");
            const diffMs = forecastDate - now;
            const diffHours = Math.round(diffMs / (1000 * 60 * 60));
            let relativeTime = "";
            if (diffHours > 0)
                relativeTime = "in " + diffHours + "h";
            else if (diffHours === 0)
                relativeTime = "now";
            else
                relativeTime = Math.abs(diffHours) + "h ago";

            weatherForecast.push({
                date: day.date,
                avgTemp: day.day.avgtemp_c + "°C",
                desc: day.day.condition.text,
                icon: iconChar,
                relativeTime: relativeTime
            });
        }
    }

    property string weatherIcon: ""
    property var weatherData
    property var currentCondition
    property var weatherForecast: []

    // WeatherAPI condition codes → icons
    property var weatherIcons: ({
            "Unknown": "\uf3cc",
            "Cloudy": "\ue2bd",
            "Fog": "\ue818",
            "HeavyRain": "\uf61f",
            "HeavySnow": "\uf61c",
            "LightRain": "\uf61e",
            "LightSnow": "\uf61e",
            "PartlyCloudy": "\uf172",
            "Sunny": "\ue81a",
            "ThunderyHeavyRain": "\uebdb",
            "VeryCloudy": "\ue2bd"
        })

    // Mapping of WeatherAPI condition codes to our symbolic names
    // (See https://www.weatherapi.com/docs/ for full condition codes)
    property var weatherCode: ({
            1000: "Sunny",
            1003: "PartlyCloudy",
            1006: "Cloudy",
            1009: "VeryCloudy",
            1030: "Fog",
            1063: "LightRain",
            1066: "LightSnow",
            1069: "LightRain",
            1072: "LightRain",
            1087: "ThunderyHeavyRain",
            1114: "HeavySnow",
            1117: "HeavySnow",
            1135: "Fog",
            1147: "Fog",
            1150: "LightRain",
            1153: "LightRain",
            1180: "LightRain",
            1183: "LightRain",
            1186: "HeavyRain",
            1189: "HeavyRain",
            1192: "HeavyRain",
            1195: "HeavyRain",
            1204: "LightSnow",
            1207: "HeavySnow",
            1210: "LightSnow",
            1213: "LightSnow",
            1216: "LightSnow",
            1219: "LightSnow",
            1222: "HeavySnow",
            1225: "HeavySnow",
            1273: "ThunderyHeavyRain",
            1276: "ThunderyHeavyRain",
            1279: "HeavySnow",
            1282: "HeavySnow"
        })

    function getIconFromCode(code) {
        if (!(code in weatherCode))
            return "\uf3cc";
        const desc = weatherCode[code];
        if (!(desc in weatherIcons))
            return "\uf3cc";
        return weatherIcons[desc];
    }

    Component.onCompleted: {
        fetchWeather();
    }
}
