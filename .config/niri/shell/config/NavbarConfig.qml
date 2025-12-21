import Quickshell.Io

JsonObject {
    property string position: "top" // top, bottom, left, right
    property bool side: position === "left" || position === "right"
    property int width: 50
    property int height: 50
}
