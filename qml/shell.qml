import QtQuick
import QtQuick.Controls
import QtQuick.Window
import Quickshell

ShellRoot {
    FloatingWindow {
        title: 'test'
        minimumSize: Qt.size(screen.width / 4, screen.height / 2)
        color: 'transparent'
        Item {
            id: layered
            opacity: 0.5
            property bool open: false
            anchors.fill: parent
            anchors.margins: 1

            ListModel {
                id: rectModel
                ListElement {
                    openY: 120
                    closedY: 10
                    offset: 20
                }
                ListElement {
                    openY: 60
                    closedY: 5
                    offset: 10
                }
                ListElement {
                    openY: 0
                    closedY: 0
                    offset: 0
                }
            }

            Repeater {
                model: rectModel
                delegate: Rectangle {
                    y: layered.open ? model.openY : model.closedY
                    x: (parent.width - width) / 2
                    width: layered.open ? parent.width : parent.width - model.offset
                    height: 60
                    border.width: 1

                    Behavior on width {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.InOutQuad
                        }
                    }

                    Behavior on y {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: layered.open = !layered.open
            }
        }
    }
}
