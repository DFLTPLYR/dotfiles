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

    ListView {
        id: todoListView
        Layout.fillHeight: true
        Layout.fillWidth: true
        spacing: 1
        focus: true
        keyNavigationWraps: true
        keyNavigationEnabled: true

        boundsBehavior: Flickable.StopAtBounds
        snapMode: GridView.NoSnap

        ListModel {
            id: todoModel
        }
        model: todoModel

        delegate: Rectangle {
            id: delegateRect
            width: parent.width

            property int preferredHeight: 40
            property int expandedHeight: task.height + preferredHeight

            property bool expanded: false

            height: expanded ? expandedHeight : preferredHeight

            Behavior on height {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }

            radius: 5
            color: mouse.hovered ? (model.is_completed ? Scripts.setOpacity(Assets.color10, 0.4) : Scripts.setOpacity(Assets.color10, 0.4)) : (model.is_completed ? Scripts.setOpacity(Assets.color10, 0.2) : Scripts.setOpacity(Assets.color11, 0.2))

            property bool isSelected: ListView.isCurrentItem

            Behavior on color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }

            HoverHandler {
                id: mouse
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            }

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
                        color: mouse.hovered ? Scripts.setOpacity(Assets.color12, 0.4) : "transparent"

                        Behavior on color {
                            ColorAnimation {
                                duration: 400
                                easing.type: Easing.InOutQuad
                            }
                        }

                        Text {
                            id: checked
                            visible: model.is_completed
                            anchors.centerIn: parent
                            text: qsTr("\ue5ca")
                            color: Assets.color10
                            font.family: FontAssets.fontMaterialOutlined
                            font.pixelSize: Math.round(parent.height)
                        }

                        Text {
                            id: closed
                            visible: !model.is_completed
                            color: Assets.color10
                            anchors.centerIn: parent
                            text: qsTr("\ue5cd")
                            font.pixelSize: Math.round(parent.height)
                            font.family: FontAssets.fontMaterialOutlined
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                var id = model.id;
                                var todo = {
                                    title: model.title,
                                    status: !model.is_completed ? "completed" : "pending",
                                    is_completed: !model.is_completed ? true : false
                                };
                                TodoService.updateTodo(id, todo, function (res, err) {
                                    if (!err) {
                                        model.id = res.id;
                                        model.title = res.title;
                                        model.status = res.status;
                                        model.is_completed = !!res.is_completed;

                                        var oldIndex = index;
                                        var newIndex = -1;
                                        if (model.is_completed) {
                                            newIndex = todoModel.count - 1;
                                        } else {
                                            for (var i = 0; i < todoModel.count; ++i) {
                                                if (todoModel.get(i).is_completed) {
                                                    newIndex = i;
                                                    break;
                                                }
                                            }
                                            if (newIndex === -1)
                                                newIndex = todoModel.count - 1;
                                        }
                                        if (oldIndex !== newIndex) {
                                            todoModel.move(oldIndex, newIndex, 1);
                                        }
                                    }
                                });
                            }
                        }
                    }
                }

                Text {
                    id: task
                    text: model.title
                    color: Assets.color10

                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    horizontalAlignment: Text.AlignHCenter

                    font.strikeout: model.is_completed

                    elide: delegateRect.expanded ? Text.ElideNone : Text.ElideRight
                    wrapMode: delegateRect.expanded ? Text.Wrap : Text.NoWrap

                    clip: true

                    MouseArea {
                        anchors.fill: parent
                        onClicked: delegateRect.expanded = !delegateRect.expanded
                    }
                }

                Item {
                    height: parent.height
                    width: height
                    opacity: mouse.hovered ? 1 : 0

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
                            color: Assets.color10
                        }

                        MouseArea {
                            id: deleteAction
                            height: removeWrapper.height
                            width: removeWrapper.width
                            cursorShape: Qt.PointingHandCursor
                            acceptedButtons: Qt.LeftButton
                            onClicked: {
                                TodoService.deleteTodo(model.id, function (res, err) {
                                    if (!err) {
                                        if (typeof index !== "undefined") {
                                            todoModel.remove(index);
                                        } else {
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
        move: Transition {
            NumberAnimation {
                properties: "x,y"
                duration: 250
            }
        }
        moveDisplaced: Transition {
            NumberAnimation {
                properties: "x,y"
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
            let sorted = response.offline.sort(function (a, b) {
                return a.is_completed - b.is_completed;
            });
            for (var todo of sorted) {
                todoModel.append({
                    id: todo.id,
                    title: todo.title,
                    status: todo.status,
                    is_completed: !!todo.is_completed
                });
            }
        });
    }
}
