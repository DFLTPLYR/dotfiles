// WeatherFetcher.qml
pragma Singleton

import Quickshell
import QtQuick
import Quickshell.Io

Singleton {
    id: root

    property string weatherInfo: ""
    property string weatherCondition: ""
    property string weatherIcon: ""

    // Weather icon codes
    property var weatherIcons: ({
            cloud: '\uf1c0',
            thunder: '\uf0e7',
            rainy: '\uf73d',
            wet: '\uf0e9',
            sunny: '\uf185',
            windy: '\uf72e',
            unknown: '\uf128' // fallback icon
        })

    Process {
        id: weatherProc
        running: true
        command: ["curl", "wttr.in/manila?format=%t%20%c"]
        stdout: StdioCollector {
            onStreamFinished: {
                const out = this.text.trim();
                root.weatherInfo = out;

                const parts = out.split(" ");
                const icon = parts.length > 1 ? parts[1] : "";
                const lowerIcon = icon.toLowerCase();

                let condition = "unknown";

                if (icon.includes("☀") || lowerIcon.includes("sun")) {
                    condition = "sunny";
                } else if (icon.includes("🌧") || icon.includes("🌦") || lowerIcon.includes("rain")) {
                    condition = "rainy";
                } else if (icon.includes("☁") || lowerIcon.includes("cloud")) {
                    condition = "cloud";
                } else if (icon.includes("🌩") || icon.includes("⚡")) {
                    condition = "thunder";
                } else if (icon.includes("💧") || icon.includes("🌫")) {
                    condition = "wet";
                } else if (icon.includes("💨") || lowerIcon.includes("wind")) {
                    condition = "windy";
                }

                weatherCondition = condition;
                weatherIcon = weatherIcons[condition] || weatherIcons.unknown;
            }
        }
    }

    // Function to fetch weather
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
