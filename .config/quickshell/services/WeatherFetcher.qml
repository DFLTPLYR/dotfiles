// WeatherFetcher.qml
pragma Singleton

import Quickshell
import QtQuick
import Quickshell.Io

Singleton {
    id: root

    property string weatherInfo: "" // e.g., "32°C"
    property string weatherCondition: "" // e.g., "sunny"
    property string weatherIcon: "" // FontAwesome or your custom icon
    property var weatherData: {} // Full raw JSON if needed

    property var weatherIcons: ({
            cloud: '\uf1c0',
            thunder: '\uf0e7',
            rainy: '\uf73d',
            wet: '\uf0e9',
            sunny: '\uf185',
            windy: '\uf72e',
            unknown: '\uf128'
        })

    Process {
        id: weatherProc
        running: false
        command: ["curl", "wttr.in/manila?format=j1"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const json = JSON.parse(this.text.trim());
                    root.weatherData = json;

                    const current = json.current_condition[0];
                    const temp = current.temp_C + "°C";
                    const desc = current.weatherDesc[0].value.toLowerCase();

                    root.weatherInfo = temp;
                    console.log(desc);

                    let condition = "unknown";

                    if (desc.includes("sun")) {
                        condition = "sunny";
                    } else if (desc.includes("rain")) {
                        condition = "rainy";
                    } else if (desc.includes("cloud")) {
                        condition = "cloud";
                    } else if (desc.includes("thunder")) {
                        condition = "thunder";
                    } else if (desc.includes("mist") || desc.includes("fog") || desc.includes("drizzle")) {
                        condition = "wet";
                    } else if (desc.includes("wind")) {
                        condition = "windy";
                    }

                    root.weatherCondition = condition;
                    root.weatherIcon = weatherIcons[condition] || weatherIcons.unknown;
                } catch (e) {
                    console.warn("Failed to parse weather JSON:", e);
                }
            }
        }
    }

    function fetchWeather() {
        weatherProc.running = true;
    }

    Timer {
        id: refreshTimer
        interval: 600000 // 10 minutes
        repeat: true
        running: true
        triggeredOnStart: true

        onTriggered: fetchWeather()
    }

    Component.onCompleted: fetchWeather()
}
