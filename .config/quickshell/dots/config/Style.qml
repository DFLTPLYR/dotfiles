import Quickshell.Io
import QtQuick

JsonObject {
    property bool usePanel: false
    property string panelSource: ""
    property int borderWidth: 0
    property color borderColor: "transparent"
    property color color: Colors.color.primary
    property JsonObject margin: JsonObject {
        property int left: 0
        property int right: 0
        property int top: 0
        property int bottom: 0
    }
    property JsonObject rounding: JsonObject {
        property int left: 0
        property int right: 0
        property int top: 0
        property int bottom: 0
    }
}
