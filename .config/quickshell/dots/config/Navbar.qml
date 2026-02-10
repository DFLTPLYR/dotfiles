pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import QtCore

import Quickshell
import Quickshell.Io

import qs.config

Singleton {
    id: navbar
    property alias config: adapter.navbar
    property alias extended: adapter.extendedbar

    property bool extendedOpen: false

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
        JsonAdapter {
            id: adapter
            property NavbarConfig navbar: NavbarConfig {}
            property ExtendedBarConfig extendedbar: ExtendedBarConfig {}
        }
    }

    function saveSettings() {
        fileView.writeAdapter();
    }
}
