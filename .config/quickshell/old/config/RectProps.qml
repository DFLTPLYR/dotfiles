import Quickshell.Io
import qs.assets

JsonObject {
    property string color: Color.background
    property int height: 50
    property JsonObject anchors: JsonObject {
        property bool top: true
        property bool left: true
        property bool bottom: true
        property bool right: true
    }
    property JsonObject margins: JsonObject {
        property int top: 10
        property int left: 10
        property int bottom: 0
        property int right: 10
    }
    property JsonObject rounding: JsonObject {
        property int topLeft: 0
        property int topRight: 0
        property int bottomLeft: 0
        property int bottomRight: 0
    }
}
