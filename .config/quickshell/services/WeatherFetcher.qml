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
            "Cloudy": "\uE2BD",
            "Overcast": "\uE2BD",
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

    // ...existing code...
    function parseWeather(json) {
        root.weatherData = json || {};
        const current = (json && json.current_condition && json.current_condition[0]) ? json.current_condition[0] : null;
        root.weatherInfo = current && current.temp_C ? (current.temp_C + "°C") : "";

        const desc = (current && current.weatherDesc && current.weatherDesc[0] && current.weatherDesc[0].value) ? current.weatherDesc[0].value : "";
        let condition = desc ? iconKeyForDesc(desc) : "unknown";
        root.weatherCondition = condition;

        const ICON_LABEL_MAP = {
            drizzle: "Showers",
            sunny: "Sunny",
            clear: "Clear",
            rainy: "Rain",
            rain: "Rain",
            cloud: "Cloudy",
            thunder: "Thunderstorm",
            wet: "Mist",
            windy: "Windy",
            snowy: "Snow",
            hail: "Sleet",
            extreme: "Tornado",
            dusty: "Haze",
            unknown: "Clear"
        };

        const iconLabel = ICON_LABEL_MAP[condition] || "Clear";
        root.weatherIcon = (root.weatherIcons && root.weatherIcons[iconLabel]) ? root.weatherIcons[iconLabel] : "";
        root.weatherForecast = [];
        const forecastArr = (json && json.weather) ? json.weather : [];
        const now = new Date();

        for (let i = 0; i < Math.min(forecastArr.length, 3); i++) {
            const day = forecastArr[i] || {};
            const hourly = day.hourly || [];
            const noonHour = hourly[4] || hourly[0] || null;
            const noonDesc = (noonHour && noonHour.weatherDesc && noonHour.weatherDesc[0] && noonHour.weatherDesc[0].value) ? noonHour.weatherDesc[0].value : "";

            const fk = noonDesc ? iconKeyForDesc(noonDesc) : "unknown";
            const fkLabel = ICON_LABEL_MAP[fk] || "Clear";
            const iconChar = (root.weatherIcons && root.weatherIcons[fkLabel]) ? root.weatherIcons[fkLabel] : "";

            // safe time parsing
            let timeStr = "12:00";
            if (noonHour && noonHour.time) {
                timeStr = noonHour.time.toString().padStart(4, "0").replace(/(\d{2})(\d{2})/, "$1:$2");
            }
            const forecastDate = new Date((day.date || "") + " " + timeStr);
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
                date: day.date || "",
                avgTemp: day.avgtempC ? (day.avgtempC + "°C") : "",
                desc: noonDesc,
                icon: iconChar,
                relativeTime: relativeTime
            });
        }
    }
    // ...existing code...

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
