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
            "Sunny": "\uE430",
            "Clear": "\uE430",
            "Partly cloudy": "\uE42C",
            "Cloudy": "\uE42B",
            "Overcast": "\uE42B",
            "Mist": "\uE3BD",
            "Fog": "\uE3BD",
            "Haze": "\uE3BD",
            "Rain": "\uE4F7",
            "Light rain": "\uE4F7",
            "Heavy rain": "\uE4F7",
            "Showers": "\uE4F7",
            "Thunderstorm": "\uE409",
            "Snow": "\uEB3B",
            "Light snow": "\uEB3B",
            "Heavy snow": "\uEB3B",
            "Sleet": "\uE50B",
            "Windy": "\uE429",
            "Tornado": "\uE7C9"
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

    function fetchWeather() {
        const xhr = new XMLHttpRequest();
        xhr.open("GET", "https://wttr.in/manila?format=j1");
        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        const json = JSON.parse(xhr.responseText);
                        root.parseWeather(json);
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

    Timer {
        id: refreshTimer
        interval: 600000 // 10 minutes
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: fetchWeather()
    }
}
