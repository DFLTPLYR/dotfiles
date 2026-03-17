import QtQuick
import Quickshell

Variants {
    model: Quickshell.screens
    delegate: PanelWindow {
        implicitWidth: screen.width
        implicitHeight: screen.height
        required property ShellScreen modelData
        color: "transparent"
        mask: Region {}

        Top {
            screen: modelData
        }

        Background {
            screen: modelData
        }

        Overlay {
            screen: modelData
        }
    }
}
