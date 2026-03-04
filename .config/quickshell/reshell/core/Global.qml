pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

import qs.types

Singleton {
    id: config
    property bool enableSetting: false
    property alias general: adapter
    property alias icon: customIconFont.font

    FontLoader {
        id: customIconFont
        source: Qt.resolvedUrl("./icon.otf")
    }

    FileView {
        id: fileView
        path: Qt.resolvedUrl("./general.json")
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
            property BorderJson border: BorderJson {}
            property DirectionJson margin: DirectionJson {}
            property CornerJson rounding: CornerJson {}
            // set it to 0.0 hehe haha moment
            property real opacity: 0.5
        }
    }

    IpcHandler {
        target: "config"
        function toggleWallpaperPicker() {
        }

        function toggleAppLauncher() {
        }

        function toggleSessionMenu() {
        }

        function toggleExtendedBar() {
        }

        function toggleSettingsPanel() {
            config.enableSetting = !config.enableSetting;
        }
    }
}
