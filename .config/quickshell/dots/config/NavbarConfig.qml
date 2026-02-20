import QtQuick
import Quickshell.Io

JsonObject {
    property list<var> layouts: []
    property list<var> widgets: []
    property int width: 50
    property int height: 50
    property string position: "top" // top, bottom, left, right
    property bool side: position === "left" || position === "right"
    property color background: Colors.color.background
    property PopupProps popup: PopupProps {}
    property Style style: Style {}
}
