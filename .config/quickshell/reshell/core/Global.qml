pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: config
    property bool enableSetting: false

    property alias icon: customIconFont.font

    FontLoader {
        id: customIconFont
        source: Qt.resolvedUrl("./icon.otf")
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
