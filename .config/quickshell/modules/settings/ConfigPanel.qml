import QtQuick

import Quickshell
import Quickshell.Hyprland

Scope {
    id: root

    property bool shouldBeVisible: false
    property real animProgress: 0

    GlobalShortcut {
        name: "showSettingsPanel"
        description: "Show Settings Panel"

        onPressed: {
            if (root.shouldBeVisible) {
                root.shouldBeVisible = false;
                root.animProgress = 0;
                return;
            }
            // if (Hyprland.focusedMonitor.name !== screenRoot.screen.name)
            //     return;

            root.shouldBeVisible = true;
            root.animProgress = root.shouldBeVisible ? 1 : 0;
        }
    }

    Loader {
        active: root.shouldBeVisible
        sourceComponent: settingPanel {
            id: settingPanel
        }
    }

    Component {
        id: settingPanel
        FloatingWindow {
            id: floatingPanel

            color: Qt.rgba(0.33, 0.33, 0.41, 0.78)

            property bool isPortrait: screen.height > screen.width

            minimumSize: Qt.size(screen.width / 2, screen.height / 1.5)
            maximumSize: Qt.size(screen.width / 2, screen.height / 1.5)
        }
    }
}
