pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

import qs.config

Singleton {
    property alias loaded: fileView.loaded
    property alias navbar: adapter.navbarConfig

    FileView {
        id: fileView
        path: Qt.resolvedUrl("./config.json")
        watchChanges: true
        preload: true
        onLoaded: console.log("Default Config Loaded")
        onFileChanged: {
            reload();
        }
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound) {
                fileView.setText("{}");
                fileView.writeAdapter();
            }
        }
        onAdapterUpdated: {
            if (loaded)
                return writeAdapter();
        }
        JsonAdapter {
            id: adapter
            property NavbarConfig navbarConfig: NavbarConfig {}
        }
    }
}
