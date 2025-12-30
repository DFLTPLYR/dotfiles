import QtQuick
import QtQuick.Controls

import Quickshell
import Quickshell.Wayland

import qs.config
import qs.components

Variants {
    model: Quickshell.screens
    delegate: PanelWindow {
        id: root
        required property ShellScreen modelData
        readonly property bool isPortrait: screen.height > screen.width
        screen: modelData

        SystemClock {
            id: clock
            precision: SystemClock.Seconds
        }

        anchors {
            top: true
            left: true
            right: true
        }

        implicitWidth: containerRect.width
        implicitHeight: containerRect.height

        color: "transparent"

        // parent
        StyledRect {
            id: containerRect
            width: Config.navbar.side ? Config.navbar.width : screen.width
            height: Config.navbar.side ? screen.height : Config.navbar.height
            color: Qt.rgba(0, 0, 0, 0.5)

            Text {
                font.pixelSize: Math.min(containerRect.height, containerRect.width) / 2
                text: Qt.formatDateTime(clock.date, "hh:mm AP")
                color: "white"
                anchors {
                    verticalCenter: parent.verticalCenter
                    horizontalCenter: parent.horizontalCenter
                }
            }

            StyledIconButton {
                height: parent.height
                width: height
                iconRounding: height
                iconMargin: 10
                iconSource: Quickshell.iconPath(Quickshell.shellDir + "/assets/powerbtn.svg", true)
                onClicked: {
                    // Quickshell.execDetached({
                    //     command: ["sh", "-c", "shutdown now"]
                    // });
                    Config.openSessionMenu = !Config.openSessionMenu;
                }
            }
        }

        PopupWindow {
            visible: false
            color: "transparent"
            implicitWidth: {
                let percent = 0.5;
                if (root.isPortrait) {
                    return Math.max(screen.width * percent, screen.width * 0.5);
                } else {
                    return Math.max(screen.width * percent, screen.width * 0.5);
                }
            }
            implicitHeight: screen.height * 0.3
            anchor {
                window: root
                rect {
                    x: Config.navbar.side ? Config.navbar.width : screen.width / 2 - width / 2
                    y: Config.navbar.side ? screen.height / 2 - height / 2 : Config.navbar.height
                }
            }

            Rectangle {
                anchors.fill: parent
                color: "green"
                opacity: 1
            }
        }

        Component.onCompleted: {
            if (this.WlrLayershell != null) {
                this.WlrLayershell.layer = WlrLayer.Top;
                this.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None;
            }
        }
    }
}
