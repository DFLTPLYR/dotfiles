import QtQuick
import Quickshell.Io

JsonObject {
    property int height: 2
    property int width: 200

    property color color: "transparent"

    property BorderJson border: BorderJson {}
    property DirectionJson margin: DirectionJson {}
    property CornerJson rounding: CornerJson {}

    property list<var> gradient: []
}
