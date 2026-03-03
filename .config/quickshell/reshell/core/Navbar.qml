pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick

import Quickshell
import Quickshell.Io

import qs.types

Singleton {
    id: navbar
    property alias config: adapter.config

    FileView {
        id: fileView
        path: Qt.resolvedUrl("./navbar.json")
        watchChanges: true
        preload: true
        onFileChanged: {
            reload();
        }
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound) {
                fileView.setText("{}");
                fileView.writeAdapter();
            }
        }
        adapter: JsonAdapter {
            id: adapter
            property Navbar config: Navbar {}
        }
    }

    component Navbar: JsonObject {
        property int height: 40
        property int width: 40

        property string position: "top" // top, bottom, left, right
        readonly property bool side: position === "left" || position === "right"

        property StyleJson style: StyleJson {
            border {
                width: 1
                color: Colors.color.primary
            }
        }

        property list<var> layouts: []
        property list<var> widgets: []
    }
}
