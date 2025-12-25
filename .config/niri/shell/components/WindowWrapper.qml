import QtQuick
import Quickshell

Variants {
    model: Quickshell.screens
    delegate: PanelWindow {
        required property ShellScreen modelData
        screen: modelData

        anchors {
            top: true
            bottom: true
            right: true
            left: true
        }

        contentItem {
            focus: true
            Keys.onPressed: event => {
                if (event.key == Qt.Key_Escape) {
                    Config.sessionMenuOpen = false;
                }
            }
        }
    }
}
