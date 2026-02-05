pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string path: `${Quickshell.env("XDG_RUNTIME_DIR")}/pdaemon.sock`

    property string location: ""
    property string condition: ""
    property double temperatureC: 0
    property double temperatureF: 0
    property double feelsLikeC: 0
    property double feelsLikeF: 0
    property int humidity: 0
    property double windKph: 0
    property double windMph: 0
    property string windDir: ""
    property double pressureMb: 0
    property double pressureIn: 0
    property string sunrise: ""
    property string sunset: ""
    property list<var> forecast: []

    property bool ready: false
    property string lastError: ""

    Socket {
        id: socket
        connected: true
        path: root.path
        onConnectedChanged: {
            write('weather\n');
        }
        parser: SplitParser {
            onRead: line => {
                root._handleLine(line);
            }
        }
        onError: err => {
            root.lastError = err;
        }
    }

    function _handleLine(line) {
        try {
            var data = JSON.parse(line);

            root.location = data.location || "";
            root.condition = data.condition || "";
            root.temperatureC = data.temp_c || 0;
            root.temperatureF = data.temp_f || 0;
            root.feelsLikeC = data.feelslike_c || 0;
            root.feelsLikeF = data.feelslike_f || 0;
            root.humidity = data.humidity || 0;
            root.windKph = data.wind_kph || 0;
            root.windMph = data.wind_mph || 0;
            root.windDir = data.wind_dir || "";
            root.pressureMb = data.pressure_mb || 0;
            root.pressureIn = data.pressure_in || 0;
            root.sunrise = data.sunrise || "";
            root.sunset = data.sunset || "";
            root.forecast = data.forecast.forecastday || "";
            root.ready = true;
        } catch (e) {
            root.lastError = e.toString();
        }
    }
}
