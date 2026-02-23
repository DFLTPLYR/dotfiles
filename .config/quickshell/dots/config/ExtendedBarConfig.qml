import QtQuick
import Quickshell.Io

JsonObject {
    property int width: 500
    property JsonObject padding: JsonObject {
        property int left: 0
        property int right: 0
        property int top: 0
        property int bottom: 0
    }
    property JsonObject margin: JsonObject {
        property int left: 0
        property int right: 0
        property int top: 0
        property int bottom: 0
    }
    property int height: 500
    property real axisRatio: 1.0
}
