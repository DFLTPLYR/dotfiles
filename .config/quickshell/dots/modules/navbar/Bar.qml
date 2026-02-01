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
        WlrLayershell.namespace: "navbar"
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

        implicitWidth: Config.navbar.side ? Config.navbar.width : screen.width
        implicitHeight: Config.navbar.side ? screen.height : Config.navbar.height

        color: "transparent"
        Behavior on anchors {
            AnchorAnimation {
                targets: root
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }
        StyledRect {
            id: containerRect
            color: Config.navbar.background
            anchors.fill: parent

            Behavior on height {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }
            Behavior on width {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }
            GridLayout {
                anchors.fill: parent
                columns: Config.navbar.side ? 1 : Config.navbar.layouts.length
                rows: Config.navbar.side ? Config.navbar.layouts.length : 1
                Repeater {
                    id: slotRepeater
                    model: ScriptModel {
                        values: Config.navbar.layouts
                    }
                    delegate: StyledSlot {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        required property var modelData
                        position: modelData.direction
                    }
                }
            }
        }
        // parent
        // StyledRect {
        //
        //     GridLayout {
        //         anchors.fill: parent
        //         columns: 3
        //         rows: 1
        //
        //         Item {
        //             Layout.fillHeight: true
        //             Layout.fillWidth: true
        //         }
        //
        //         Item {
        //             Layout.fillHeight: true
        //             Layout.fillWidth: true
        //             Text {
        //                 font.pixelSize: Math.min(containerRect.height, containerRect.width) / 2
        //                 text: Qt.formatDateTime(clock.date, "hh:mm AP")
        //                 color: "white"
        //                 anchors {
        //                     verticalCenter: parent.verticalCenter
        //                     horizontalCenter: parent.horizontalCenter
        //                 }
        //             }
        //         }
        //
        //         Item {
        //             Layout.fillHeight: true
        //             Layout.fillWidth: true
        //             StyledIconButton {
        //                 anchors.verticalCenter: parent.verticalCenter
        //                 width: parent.height / 1.5
        //                 height: parent.height / 1.5
        //                 radius: width / 2
        //
        //                 Text {
        //                     font.family: Config.iconFont.family
        //                     font.weight: Config.iconFont.weight
        //                     font.styleName: Config.iconFont.styleName
        //                     font.pixelSize: Math.min(containerRect.height, containerRect.width) / 2
        //
        //                     color: "white"
        //                     anchors {
        //                         verticalCenter: parent.verticalCenter
        //                         horizontalCenter: parent.horizontalCenter
        //                     }
        //                     text: "power-off"
        //                 }
        //
        //                 onAction: {
        //                     Config.openSessionMenu = !Config.openSessionMenu;
        //                 }
        //             }
        //         }
        //     }
        // }

        LazyLoader {
            id: extendedBarLoader
            property bool shouldBeVisible: false
            component: PopupWrapper {
                shouldBeVisible: extendedBarLoader.shouldBeVisible

                anchor {
                    item: containerRect
                    rect {
                        x: parentWindow.width / 2 - width / 2
                        y: parentWindow.height
                    }
                    margins {
                        top: 0
                        bottom: 0
                        right: 0
                        left: 0
                    }
                }

                implicitWidth: 500
                implicitHeight: 500
                color: "transparent"

                onHide: {
                    extendedBarLoader.shouldBeVisible = false;
                    extendedBarLoader.active = false;
                }

                Rectangle {
                    id: container
                    color: containerRect.color
                    implicitWidth: parent.width
                    implicitHeight: Math.max(1, parent.width * animProgress)
                    y: height * animProgress - (implicitHeight)

                    bottomLeftRadius: 50
                    bottomRightRadius: 50
                    Behavior on height {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.InOutQuad
                        }
                    }
                    Behavior on y {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }
        }

        Connections {
            target: Config
            function onOpenExtendedBarChanged() {
                if (screen.name === Config.focusedMonitor.name) {
                    extendedBarLoader.active = true;
                    extendedBarLoader.shouldBeVisible = !extendedBarLoader.shouldBeVisible;
                } else {
                    if (extendedBarLoader.active) {
                        extendedBarLoader.shouldBeVisible = !extendedBarLoader.shouldBeVisible;
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
