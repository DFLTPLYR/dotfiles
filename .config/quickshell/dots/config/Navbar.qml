pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import QtCore
import Qt.labs.folderlistmodel

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

    FolderListModel {
        id: folderModel
        folder: Qt.resolvedUrl("../widgets")
        nameFilters: ["*.qml"]
        showDirs: false

        onCountChanged: {
            for (let i = 0; i < count; i++) {
                const fileName = get(i, "fileName");
                if (fileName !== "Wrapper.qml") {
                    const widgetName = fileName.replace('.qml', '');
                    const exists = navbar.config.widgets?.find(s => s.name === widgetName);
                    if (!exists) {
                        config.widgets.push({
                            name: fileName,
                            width: 50,
                            height: 50,
                            enableActions: true,
                            icon: "clock-nine",
                            layout: "",
                            position: 0
                        });
                        saveSettings();
                    }
                }
            }
        }
    }

    function saveSettings() {
        fileView.writeAdapter();
    }
}
