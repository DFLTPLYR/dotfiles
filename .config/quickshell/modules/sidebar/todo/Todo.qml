import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.services
import qs.assets
import qs.utils

ColumnLayout {
    Layout.fillWidth: true
    Layout.fillHeight: true

    RowLayout {
        Layout.fillWidth: true
        implicitHeight: 32

        TextField {
            id: singleline
            text: ""
            color: Assets.color13

            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.fillWidth: true

            background: Rectangle {
                radius: 5
                border.color: singleline.focus ? Assets.color12 : Assets.color10
                color: "transparent"
            }
            placeholderText: "Add a new task..."
            Behavior on color {
                ColorAnimation {
                    duration: 2000
                    easing.type: Easing.InOutQuad
                }
            }

            onAccepted: {
                if (singleline.text.trim().length === 0)
                    return;
                todoModel.append({
                    text: singleline.text
                });
                singleline.text = "";
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            text: qsTr("\uf0fe")
            color: Assets.color12
            font.pixelSize: Math.min(parent.height, parent.width) * 0.8

            MouseArea {
                id: addBtnArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    if (singleline.text.trim().length === 0)
                        return;
                    todoModel.append({
                        text: singleline.text
                    });
                    singleline.text = "";
                }
            }
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
            }

            Repeater {
                model: todoModel
                delegate: Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    radius: 5
                    color: ma.containsMouse ? Scripts.setOpacity(Assets.color11, 0.2) : 'transparent'

                    RowLayout {
                        anchors.fill: parent

                        Item {
                            height: parent.height
                            width: height

                            Rectangle {
                                anchors.centerIn: parent
                                height: parent.height / 2
                                width: height
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

                            text: model.text
                            color: Scripts.setOpacity(Assets.color11, 1)
                        }

                        Item {
                            height: parent.height
                            width: height
                            opacity: ma.containsMouse ? 1 : 0

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 180
                                    easing.type: Easing.InOutQuad
                                }
                            }

                            Rectangle {
                                anchors.centerIn: parent
                                height: parent.height / 2
                                width: height
                                radius: 10
                                color: Scripts.setOpacity(Assets.color12, 0.2)
                                Text {
                                    anchors.centerIn: parent
                                    text: qsTr("\ue5cd")
                                    font.family: FontAssets.fontMaterialOutlined
                                    color: Scripts.setOpacity(Assets.color10, 1)
                                }
                            }
                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                            easing.type: Easing.InOutQuad
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
