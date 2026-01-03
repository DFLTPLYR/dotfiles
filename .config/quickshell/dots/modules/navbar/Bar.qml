import QtQuick
import QtQuick.Layouts
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
            left: ["left", "top", "bottom"].includes(Config.navbar.position)
            right: ["right", "top", "bottom"].includes(Config.navbar.position)
            top: ["right", "top", "left"].includes(Config.navbar.position)
            bottom: ["right", "bottom", "left"].includes(Config.navbar.position)
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

            anchors.fill: parent
            GridLayout {
                anchors.fill: parent
                columns: 3
                rows: 1

                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }

                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Text {
                        font.pixelSize: Math.min(containerRect.height, containerRect.width) / 2
                        text: Qt.formatDateTime(clock.date, "hh:mm AP")
                        color: "white"
                        anchors {
                            verticalCenter: parent.verticalCenter
                            horizontalCenter: parent.horizontalCenter
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    StyledIconButton {
                        width: parent.height
                        height: parent.height

                        Text {
                            font.family: Config.iconFont.family
                            font.weight: Config.iconFont.weight
                            font.styleName: Config.iconFont.styleName
                            font.pixelSize: parent.height

                            color: "white"
                            anchors {
                                verticalCenter: parent.verticalCenter
                            }
                            text: "power-off"
                        }

                        onAction: {
                            Config.openSessionMenu = !Config.openSessionMenu;
                        }
                    }
                }
            }
        }

        LazyLoader {
            id: extendedBarLoader
            property bool shouldBeVisible: false
            component: PopupWrapper {
                anchor.window: root
                shouldBeVisible: extendedBarLoader.shouldBeVisible

                implicitWidth: 500
                implicitHeight: 500
                color: "white"
                onHide: {
                    extendedBarLoader.shouldBeVisible = false;
                }
            }
        }

        Connections {
            target: Config
            function onOpenExtendedBarChanged() {
                if (screen.name === Config.focusedMonitor.name || extendedBarLoader.active) {
                    extendedBarLoader.active = Config.openExtendedBar;
                    extendedBarLoader.shouldBeVisible = !extendedBarLoader.shouldBeVisible;
                }
            }
        }

        Connections {
            target: Config
            function onFocusedMonitorChanged() {
                if (screen.name === Config.focusedMonitor.name || Config.openExtendedBar) {
                    extendedBarLoader.active = Config.openExtendedBar;
                    extendedBarLoader.shouldBeVisible = !extendedBarLoader.shouldBeVisible;
                } else {
                    extendedBarLoader.shouldBeVisible = false;
                }
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
