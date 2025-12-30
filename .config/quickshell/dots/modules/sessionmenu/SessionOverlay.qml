import QtQuick

import Quickshell
import Quickshell.Wayland

import qs.config
import qs.components

LazyLoader {
    active: Config.openSessionMenu
    component: Variants {
        model: Quickshell.screens
        delegate: PanelWindow {
            required property ShellScreen modelData
            screen: modelData

            color: "transparent"

            Behavior on color {
                ColorAnimation {
                    duration: 200
                }
            }

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
                        Config.openSessionMenu = false;
                    }
                }
            }

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0, 0, 0, 0.5)

                MouseArea {
                    anchors.fill: parent
                    onClicked: Config.openSessionMenu = false
                    hoverEnabled: true
                    onHoverEnabledChanged: {
                        parent.focus = hoverEnabled;
                    }
                }

                StyledRect {
                    width: parent.width * 0.5
                    height: parent.height * 0.5
                    x: parent.width * 0.25
                    y: parent.height * 0.25
                    color: Qt.rgba(0, 0, 0, 0.9)
                    borderRadius: 10

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onHoverEnabledChanged: {
                            parent.focus = hoverEnabled;
                        }
                    }
                }
            }

            Component.onCompleted: {
                if (this.WlrLayershell) {
                    this.exclusionMode = ExclusionMode.Ignore;
                    this.WlrLayershell.layer = WlrLayer.Top;
                    this.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive;
                }
            }
        }
    }
}
