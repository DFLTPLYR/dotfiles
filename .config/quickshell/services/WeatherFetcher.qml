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
            drizzle: '\uf743',
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
        const temp = current.temp_C + "°C";
        const desc = current.weatherDesc[0].value;

        root.weatherInfo = temp;

        let condition = iconKeyForDesc(desc);
        root.weatherCondition = condition;
        root.weatherIcon = root.weatherIcons[condition] || root.weatherIcons.unknown;

        root.weatherForecast = [];
        const forecastArr = json.weather;
        for (let i = 0; i < Math.min(forecastArr.length, 4); i++) {
            const day = forecastArr[i];
            const noonDesc = day.hourly[4].weatherDesc[0].value;
            let iconKey = iconKeyForDesc(noonDesc);
            root.weatherForecast.push({
                date: day.date,
                avgTemp: day.avgtempC + "°C",
                desc: day.hourly[4].weatherDesc[0].value,
                icon: root.weatherIcons[iconKey]
            });
        }
    }

    Process {
        id: weatherProc
        running: false
        command: ["curl", "wttr.in/manila?format=j1"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const json = JSON.parse(this.text.trim());
                    root.parseWeather(json);
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
        interval: 6000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: fetchWeather()
    }

    Component.onCompleted: refreshTimer.start()
}
