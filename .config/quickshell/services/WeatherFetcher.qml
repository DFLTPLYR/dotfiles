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
    property var weatherData
    property var currentCondition
    property var weatherForecast: []

    property var weatherIcons: ({
            "Unknown": "\uf3cc",
            "Cloudy": "\ue2bd",
            "Fog": "\ue818",
            "HeavyRain": "\uf61f",
            "HeavyShowers": "\uf61f",
            "HeavySnow": "\uf61c",
            "HeavySnowShowers": "\uf61c",
            "LightRain": "\uf61e",
            "LightShowers": "\uf61e",
            "LightSleet": "\uf61e",
            "LightSleetShowers": "\uf61e",
            "LightSnow": "\uf61e",
            "LightSnowShowers": "\uf61e",
            "PartlyCloudy": "\uf172",
            "Sunny": "\ue81a",
            "ThunderyHeavyRain": "\uebdb",
            "ThunderyShowers": "\uf61f",
            "ThunderySnowShowers": "\uf61f",
            "VeryCloudy": "\ue2bd"
        })

    property var weatherCode: ({
            113: "Sunny",
            116: "PartlyCloudy",
            119: "Cloudy",
            122: "VeryCloudy",
            143: "Fog",
            176: "LightShowers",
            179: "LightSleetShowers",
            182: "LightSleet",
            185: "LightSleet",
            200: "ThunderyShowers",
            227: "LightSnow",
            230: "HeavySnow",
            248: "Fog",
            260: "Fog",
            263: "LightShowers",
            266: "LightRain",
            281: "LightSleet",
            284: "LightSleet",
            293: "LightRain",
            296: "LightRain",
            299: "HeavyShowers",
            302: "HeavyRain",
            305: "HeavyShowers",
            308: "HeavyRain",
            311: "LightSleet",
            314: "LightSleet",
            317: "LightSleet",
            320: "LightSnow",
            323: "LightSnowShowers",
            326: "LightSnowShowers",
            329: "HeavySnow",
            332: "HeavySnow",
            335: "HeavySnowShowers",
            338: "HeavySnow",
            350: "LightSleet",
            353: "LightShowers",
            356: "HeavyShowers",
            359: "HeavyRain",
            362: "LightSleetShowers",
            365: "LightSleetShowers",
            368: "LightSnowShowers",
            371: "HeavySnowShowers",
            374: "LightSleetShowers",
            377: "LightSleet",
            386: "ThunderyShowers",
            389: "ThunderyHeavyRain",
            392: "ThunderySnowShowers",
            395: "HeavySnowShowers"
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

        const current = (json && json.current_condition && json.current_condition[0]) ? json.current_condition[0] : null;
        root.weatherInfo = current && current.temp_C ? (current.temp_C + "°C") : "";

        root.weatherCondition = current.weatherDesc;

        root.currentCondition = {
            weatherDesc: current.weatherDesc,
            feelslike: current.FeelsLikeC,
            temp: current.temp_C,
            icon: getIconFromCode(weatherCode),
            visibility: current.visibility,
            pressure: current.pressure,
            humidity: current.humidity,
            windSpeed: current.windspeedKmph
        };

        root.weatherIcon = getIconFromCode(current.weatherDesc);
        root.weatherForecast = [];
        const forecastArr = (json && json.weather) ? json.weather : [];
        const now = new Date();

        for (let i = 0; i < Math.min(forecastArr.length, 3); i++) {
            const day = forecastArr[i] || {};
            const hourly = day.hourly || [];
            const noonHour = hourly[4] || hourly[0] || null;
            const noonDesc = (noonHour && noonHour.weatherCode && noonHour.weatherCode[0] && noonHour.weatherCode) ? noonHour.weatherCode : "";
            const iconChar = getIconFromCode(noonDesc);
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
                desc: weatherCode[noonDesc],
                icon: iconChar,
                relativeTime: relativeTime
            });
        }
        root.parseDone();
    }

    property string location: "manila"
    function fetchWeather() {
        const xhr = new XMLHttpRequest();
        var url = "https://wttr.in/" + encodeURIComponent(location) + "?format=j1&_= " + Date.now();
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
        interval: 600000 // 10 minutes
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: fetchWeather()
    }
}
