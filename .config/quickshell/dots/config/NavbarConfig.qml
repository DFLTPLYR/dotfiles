import QtQuick
import Quickshell.Io

JsonObject {
    property string position: "top" // top, bottom, left, right
    property bool side: position === "left" || position === "right"
    property PopupProps popup: PopupProps {}
    property int width: 50
    property int height: 50
    property color background: Colors.color.background
    property list<var> layouts: []
    property list<var> widgets: []
}
