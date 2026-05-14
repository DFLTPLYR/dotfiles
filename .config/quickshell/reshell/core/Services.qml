pragma ComponentBehavior: Bound
import QtQuick

QtObject {
    property var compositor: Compositor
    property var hardware: Hardware
    property var colors: Colors

    function getService(text) {
        var match = text.match(/^(\w+)/);
        if (!match)
            return undefined;
        var name = match[1];
        return this[name.charAt(0).toLowerCase() + name.slice(1)];
    }
}
