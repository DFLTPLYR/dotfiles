import Quickshell.Io
import QtQuick
import QtCore

JsonObject {
    property var wallpapers: []
    property list<var> directory: [
        {
            name: "Default Pictures",
            path: StandardPaths.writableLocation(StandardPaths.PicturesLocation),
            removable: false
        }
    ]
}
