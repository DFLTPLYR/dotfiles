import QtQuick
import Quickshell.Io

JsonObject {
    property int top: 0
    property int bottom: 0
    property int right: 0
    property int left: 0

    function apply(data) {
        if (data.top !== undefined) top = data.top;
        if (data.bottom !== undefined) bottom = data.bottom;
        if (data.right !== undefined) right = data.right;
        if (data.left !== undefined) left = data.left;
    }
}
