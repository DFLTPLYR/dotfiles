import QtQuick
import Quickshell

ShellRoot {
    Variants {
        variants: Quickshell.screens
        PanelWindow {
            property var modelData
            screen: modelData
            anchors {
                left: true
                bottom: true
                right: true
            }
            Component.onCompleted: {
                console.log("Navbar on screen:", screen.name);
            }
        }
    }
}
