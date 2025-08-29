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
                    var todo = {
                        title: singleline.text,
                        status: 'pending',
                        completed: false
                    };
                    TodoService.createTodo(todo, function (response, err) {
                        if (!err) {
                            todoModel.append(response);
                        }
                    });
                    singleline.text = "";
                }
            }
        }
    }

    ListModel {
        id: todoModel
    }

    ListView {
        id: todoListView
        Layout.fillHeight: true
        Layout.fillWidth: true

        focus: true
        keyNavigationWraps: true
        keyNavigationEnabled: true

        boundsBehavior: Flickable.StopAtBounds
        snapMode: GridView.NoSnap

        model: todoModel

        delegate: Rectangle {
            Layout.fillWidth: true
            height: 40
            radius: 5

            color: isHovered ? Scripts.setOpacity(Assets.color11, 0.2) : 'transparent'

            property bool isHovered: false
            property bool isSelected: ListView.isCurrentItem

            RowLayout {
                anchors.fill: parent

                Item {
                    height: parent.height
                    width: height

                    Rectangle {
                        anchors.centerIn: parent
                        height: parent.height / 2
                        width: height
                        radius: 4
                        color: isHovered ? Scripts.setOpacity(Assets.color11, 0.4) : "transparent"

                        Behavior on color {
                            ColorAnimation {
                                duration: 400
                                easing.type: Easing.InOutQuad
                            }
                        }

                        Text {
                            id: checked
                            anchors.centerIn: parent
                            text: qsTr("\ue5ca")
                            font.family: FontAssets.fontMaterialOutlined
                            font.pixelSize: Math.round(parent.height)
                        }

                        Text {
                            id: closed
                            visible: false
                            anchors.centerIn: parent
                            text: qsTr("\ue5cd")
                            font.pixelSize: Math.round(parent.height)
                            font.family: FontAssets.fontMaterialOutlined
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

                    text: model.title
                    color: Scripts.setOpacity(Assets.color11, 1)
                }

                Item {
                    height: parent.height
                    width: height
                    opacity: isHovered ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 180
                            easing.type: Easing.InOutQuad
                        }
                    }

                    Rectangle {
                        id: removeWrapper
                        anchors.centerIn: parent
                        height: parent.height / 2
                        width: height
                        radius: 10
                        color: Scripts.setOpacity(Assets.color12, 0.2)

                        Text {
                            anchors.centerIn: parent
                            text: qsTr("\ue5cd")
                            font.family: FontAssets.fontMaterialOutlined
                            color: Scripts.setOpacity(Assets.color11, 1)
                        }

                        MouseArea {
                            id: deleteAction
                            height: removeWrapper.height
                            width: removeWrapper.width
                            acceptedButtons: Qt.LeftButton
                            onClicked: {
                                TodoService.deleteTodo(model.id, function (res, err) {
                                    if (!err) {
                                        // remove the delegate from the ListModel
                                        if (typeof index !== "undefined") {
                                            todoModel.remove(index);
                                        } else {
                                            // fallback: find by id
                                            for (var i = 0; i < todoModel.count; i++) {
                                                if (todoModel.get(i).id === model.id) {
                                                    todoModel.remove(i);
                                                    break;
                                                }
                                            }
                                        }
                                    } else {
                                        console.warn("deleteTodo failed", err);
                                    }
                                });
                            }
                            z: 10
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
                id: hoverArea
                anchors.fill: parent
                hoverEnabled: true

                onEntered: {
                    isHovered = true;
                    grid.currentIndex = modelData.index;
                }
                onExited: isHovered = false
                onClicked: grid.openApp()
            }
        }

        add: Transition {
            NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: 250
            }
            NumberAnimation {
                property: "x"
                from: 200
                to: 0
                duration: 250
            }
        }

        remove: Transition {
            NumberAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: 250
            }
            NumberAnimation {
                property: "x"
                to: 300
                duration: 250
            }
        }

        displaced: Transition {
            NumberAnimation {
                properties: "x,y"
                duration: 250
            }
        }
    }

    Component.onCompleted: {
        todoListView.focus = true;
        TodoService.getAllTodos(function (response) {
            for (var todo of response.offline) {
                todoModel.append(todo);
            }
        });
    }
}
