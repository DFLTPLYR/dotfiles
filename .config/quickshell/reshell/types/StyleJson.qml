import QtQuick
import Quickshell.Io

JsonObject {
    property color color: "transparent"
    property real opacity: 1
    property BorderImageJson borderImage
    property BorderJson border
    property DirectionJson margin
    property CornerJson rounding

    borderImage: BorderImageJson {
    }

    border: BorderJson {
    }

    margin: DirectionJson {
    }

    rounding: CornerJson {
    }

}
