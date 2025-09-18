// WeatherFetcher.qml
pragma Singleton

import Quickshell
import QtQuick
import Quickshell.Io

Singleton {
    id: root

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

    signal parseDone
    function getIconFromCode(code) {
        if (!(code in weatherCode))
            return "\uf3cc";
        const desc = weatherCode[code];
        if (!(desc in weatherIcons))
            return "\uf3cc";
        return weatherIcons[desc];
    }

    function parseWeather(json) {
        root.weatherData = json || {};

        const current = json.current;
        root.currentCondition = {
            weatherDesc: current.condition.text,
            feelslike: `Feels like ${current.feelslike_c}°C`,
            temp: `${current.temp_c}°C`,
            icon: getIconFromCode(current.condition.code),
            visibility: current.vis_km,
            pressure: current.pressure_mb,
            humidity: current.humidity,
            windSpeed: current.wind_kph
        };

        root.weatherIcon = getIconFromCode(current.condition.code);
        root.weatherForecast = [];

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

            root.weatherForecast.push({
                date: day.date,
                avgTemp: day.day.avgtemp_c + "°C",
                desc: day.day.condition.text,
                icon: iconChar,
                relativeTime: relativeTime
            });
        }

        root.parseDone();
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
        interval: 300000 // 10 minutes
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: fetchWeather()
    }
}
