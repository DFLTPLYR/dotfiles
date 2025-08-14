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

    function parseWeather(json) {
        root.weatherData = json;

        const current = json.current_condition[0];
        const temp = current.temp_C + "°C";
        const desc = current.weatherDesc[0].value.toLowerCase();

        root.weatherInfo = temp;

        let condition = "unknown";
        switch (true) {
        case desc.includes("sun") || desc.includes("clear"):
            condition = "sunny";
            break;
        case desc.includes("rain") || desc.includes("shower"):
            condition = "rainy";
            break;
        case desc.includes("cloud") || desc.includes("overcast") || desc.includes("partly"):
            condition = "cloud";
            break;
        case desc.includes("thunder"):
            condition = "thunder";
            break;
        case desc.includes("mist") || desc.includes("fog") || desc.includes("drizzle"):
            condition = "wet";
            break;
        case desc.includes("wind") || desc.includes("breeze") || desc.includes("gust"):
            condition = "windy";
            break;
        case desc.includes("snow") || desc.includes("sleet") || desc.includes("blizzard") || desc.includes("flurries"):
            condition = "snowy";
            break;
        case desc.includes("hail"):
            condition = "hail";
            break;
        case desc.includes("tornado") || desc.includes("hurricane") || desc.includes("cyclone"):
            condition = "extreme";
            break;
        case desc.includes("dust") || desc.includes("sand") || desc.includes("smoke"):
            condition = "dusty";
            break;
        default:
            condition = "unknown";
        }

        root.weatherCondition = condition;
        root.weatherIcon = root.weatherIcons[condition] || root.weatherIcons.unknown;

        root.weatherForecast = [];
        const forecastArr = json.weather;
        for (let i = 0; i < Math.min(forecastArr.length, 4); i++) {
            const day = forecastArr[i];
            const noonDesc = day.hourly[4].weatherDesc[0].value.toLowerCase();
            let iconKey = "unknown";
            if (noonDesc.includes("sun"))
                iconKey = "sunny";
            else if (noonDesc.includes("rain"))
                iconKey = "rainy";
            else if (noonDesc.includes("cloud"))
                iconKey = "cloud";
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
        interval: 600000 // 10 minutes
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: fetchWeather()
    }

    Component.onCompleted: fetchWeather()
}
