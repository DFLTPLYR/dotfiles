import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.services
import qs.utils
import qs.modules.sidebar.Calculator

StackLayout {
    id: container
    currentIndex: 1

    ContentWrapper {
        index: 0
        Layout.fillHeight: true
        Layout.fillWidth: true
        Calculator {}
    }
    ContentWrapper {
        index: 1
        Layout.fillHeight: true
        Layout.fillWidth: true

        RowLayout {
            Layout.fillWidth: true
            implicitHeight: 32

            TextField {
                id: singleline
                text: "asdasd"
                color: Colors.color13
                Behavior on color {
                    ColorAnimation {
                        duration: 2000
                        easing.type: Easing.InOutQuad
                    }
                }
                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                Layout.fillWidth: true

                background: Rectangle {
                    radius: 5
                    border.color: singleline.focus ? Colors.color12 : Colors.color10
                    color: "transparent"
                }
            }

            Text {
                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                text: qsTr("\uf0fe")
                color: Colors.color12
                font.pixelSize: Math.min(parent.height, parent.width) * 0.8
            }
        }

        Flickable {
            Layout.fillHeight: true
            Layout.fillWidth: true
            contentHeight: tasksColumn.height
            clip: true

            ColumnLayout {
                id: tasksColumn
                width: parent.width

                ListModel {
                    id: todoModel
                    ListElement {
                        text: "Buy groceries"
                    }
                    ListElement {
                        text: "Finish QML project"
                    }
                    ListElement {
                        text: "Call Alice"
                    }
                    ListElement {
                        text: "Read documentation"
                    }
                    ListElement {
                        text: "Walk the dog"
                    }
                }

                Repeater {
                    model: todoModel
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        height: 40
                        radius: 5
                        color: ma.containsMouse ? Scripts.setOpacity(Colors.color11, 0.5) : 'transparent'

                        RowLayout {
                            anchors.fill: parent

                            CheckBox {
                                text: qsTr("Second")
                            }
                            Text {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                                horizontalAlignment: Text.AlignHCenter
                                text: model.text
                                color: Scripts.setOpacity(Colors.color11, 1)
                            }
                        }

                        MouseArea {
                            id: ma
                            anchors.fill: parent
                            hoverEnabled: true
                        }
                    }
                }
            }
        }
    }
    ContentWrapper {
        index: 2
        Layout.fillHeight: true
        Layout.fillWidth: true
    }

    opacity: animProgress
}
