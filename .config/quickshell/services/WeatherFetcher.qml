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
    property var weatherData: {}
    property var weatherForecast: []
    property var weatherIcons: ({
            cloud: '\uf0c2',
            partlyCloudy: '\uf6c4',
            thunder: '\uf0e7',
            rainy: '\uf73d',
            wet: '\uf0e9',
            sunny: '\uf185',
            windy: '\uf72e',
            snowy: '\uf2dc',
            hail: '\uf7ad',
            dusty: '\uf72f',
            drizzle: '\uf52d',
            unknown: '\uf128'
        })

    function iconKeyForDesc(desc) {
        desc = desc.toLowerCase();
        if (desc.includes("drizzle"))
            return "drizzle";
        if (desc.includes("sun") || desc.includes("clear"))
            return "sunny";
        if (desc.includes("rain") || desc.includes("shower"))
            return "rainy";
        if (desc.includes("cloud") || desc.includes("overcast") || desc.includes("partly"))
            return "cloud";
        if (desc.includes("thunder"))
            return "thunder";
        if (desc.includes("mist") || desc.includes("fog"))
            return "wet";
        if (desc.includes("wind") || desc.includes("breeze") || desc.includes("gust"))
            return "windy";
        if (desc.includes("snow") || desc.includes("sleet") || desc.includes("blizzard") || desc.includes("flurries"))
            return "snowy";
        if (desc.includes("hail"))
            return "hail";
        if (desc.includes("tornado") || desc.includes("hurricane") || desc.includes("cyclone"))
            return "extreme";
        if (desc.includes("dust") || desc.includes("sand") || desc.includes("smoke"))
            return "dusty";
        return "unknown";
    }

    function parseWeather(json) {
        root.weatherData = json;
        const current = json.current_condition[0];
        root.weatherInfo = current.temp_C + "°C";
        let condition = iconKeyForDesc(current.weatherDesc[0].value);
        root.weatherCondition = condition;
        root.weatherIcon = root.weatherIcons[condition] || root.weatherIcons.unknown;

        root.weatherForecast = [];
        const forecastArr = json.weather;
        const now = new Date();

        for (let i = 0; i < Math.min(forecastArr.length, 3); i++) {
            const day = forecastArr[i];
            const noonHour = day.hourly[4];
            const noonDesc = noonHour.weatherDesc[0].value;
            let iconKey = iconKeyForDesc(noonDesc);

            // Calculate relative time
            const forecastDate = new Date(day.date + " " + noonHour.time.padStart(4, "0").replace(/(\d{2})(\d{2})/, "$1:$2"));
            const diffMs = forecastDate - now;
            const diffHours = Math.round(diffMs / (1000 * 60 * 60));
            let relativeTime = "";
            if (diffHours > 0)
                relativeTime = "in " + diffHours + "h";
            else if (diffHours === 0)
                relativeTime = "now";
            else
                relativeTime = Math.abs(diffHours) + "h ago";

            root.weatherForecast.push({
                date: day.date,
                avgTemp: day.avgtempC + "°C",
                desc: noonDesc,
                icon: root.weatherIcons[iconKey],
                relativeTime: relativeTime
            });
        }
    }

    Process {
        id: weatherProc
        running: true
        command: ["curl", "wttr.in/manila?format=j1"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const json = JSON.parse(this.text.trim());
                    root.parseWeather(json);
                } catch (e) {
                    console.warn("Failed to parse weather JSON:", e);
                }
                refreshTimer.interval = 600000;
            }
        }
    }

    function fetchWeather() {
        weatherProc.running = true;
    }

    Timer {
        id: refreshTimer
        interval: 1
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: fetchWeather()
    }
}
