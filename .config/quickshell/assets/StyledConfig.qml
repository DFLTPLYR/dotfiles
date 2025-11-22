import Quickshell.Io

JsonObject {
    property string color: "background"
    property JsonObject border: JsonObject {
        property int width: 0
        property string color: "transparent"
        property JsonObject radius: JsonObject {
            property int topLeft: 0
            property int topRight: 0
            property int bottomLeft: 0
            property int bottomRight: 0
        }
    }
    property JsonObject anchors: JsonObject {
        property bool fill: false
        property JsonObject margins: JsonObject {
            property int left: 0
            property int right: 0
            property int top: 0
            property int bottom: 0
        }
    }
}
