pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

import qs.config

Singleton {
    property bool sessionMenuOpen: false
    property alias loaded: fileView.loaded
    property alias navbar: adapter.navbarConfig

    FileView {
        id: fileView
        path: Qt.resolvedUrl("./config.json")
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
            property NavbarNavbar.configConfig: NavbarConfig {}
        }
    }

    function saveSettings() {
        fileView.writeAdapter();
    }
}
