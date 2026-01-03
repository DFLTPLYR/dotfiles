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

        Connections {
            target: Config
            function onOpenExtendedBarChanged() {
                if (screen.name === Config.focusedMonitor.name) {
                    popupWindow.shouldBeVisible = Config.openExtendedBar;
                }
            }
        }

        PopupWindow {
            id: popupWindow

            // Internal properties
            property bool shouldBeVisible: false
            property bool internalVisible: false
            property bool isTransitioning: false
            property real animProgress: 0.0

            // Manual animator
            NumberAnimation on animProgress {
                id: anim
                duration: 300
                easing.type: Easing.InOutQuad
            }

            onShouldBeVisibleChanged: {
                const target = shouldBeVisible ? 1.0 : 0.0;

                if (anim.to !== target || !anim.running) {
                    anim.to = target;

                    anim.restart();
                }
            }

            onAnimProgressChanged: {
                if (animProgress > 0 && !internalVisible) {
                    internalVisible = true;
                } else if (!shouldBeVisible && animProgress === 0.00) {
                    internalVisible = false;
                    if (!isTransitioning)
                        Config.openExtendedBar = false;
                }
            }

            visible: internalVisible
            color: "transparent"

            implicitWidth: contentRect.width
            implicitHeight: contentRect.height

            anchor {
                window: root
                rect {
                    x: Config.navbar.side ? Config.navbar.width : screen.width / 2 - width / 2
                    y: Config.navbar.side ? screen.height / 2 - height / 2 : Config.navbar.height
                }
            }

            Rectangle {
                id: contentRect
                height: Math.max(1, 500 * popupWindow.animProgress)
                width: 300
                color: parent.visible ? "green" : Qt.rgba(0, 0, 0, 0.5)
                opacity: 1
                y: (-100 * popupWindow.animProgress) - 100

                Behavior on y {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.InOutQuad
                    }
                }
                Behavior on opacity {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.InOutQuad
                    }
                }
                Behavior on height {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            Connections {
                target: Config
                function onFocusedMonitorChanged() {
                    if (!Config.openExtendedBar)
                        return;
                    if (popupWindow.shouldBeVisible) {
                        popupWindow.shouldBeVisible = false;
                        popupWindow.isTransitioning = true;
                    } else if (screen.name === Config.focusedMonitor.name) {
                        popupWindow.shouldBeVisible = true;
                        popupWindow.isTransitioning = false;
                    }
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
