import QtQuick
import Quickshell.Io

JsonObject {
    property int topLeft: 0
    property int topRight: 0
    property int bottomLeft: 0
    property int bottomRight: 0

    function apply(data) {
        if (data.topLeft !== undefined) topLeft = data.topLeft;
        if (data.topRight !== undefined) topRight = data.topRight;
        if (data.bottomLeft !== undefined) bottomLeft = data.bottomLeft;
        if (data.bottomRight !== undefined) bottomRight = data.bottomRight;
    }
}
