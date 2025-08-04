// WeatherFetcher.qml
pragma Singleton

import Quickshell
import QtQuick
import Quickshell.Io

Singleton {
    id: root
    property string weatherInfo: ""
    property string weatherCondition: ""

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
                    condition = "cloudy";
                } else if (icon.includes("❄") || lowerIcon.includes("snow")) {
                    condition = "snowy";
                }
                weatherCondition = condition;
            }
        }
    }
}
