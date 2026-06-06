pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

import qs.core
import qs.modules
import qs.components

Rectangle {
    id: root
    required property LockContext context
    readonly property ColorGroup colors: Window.active ? palette.active : palette.inactive
    required property ShellScreen monitor
    color: colors.window

    component LazyContainer: LazyLoader {
        id: containerloader
        required property int index
        required property var model
        property var relative: model.screens
        property var coords: {
            if (!root.monitor || !relative || !relative.count)
                return undefined;
            for (let i = 0; i < relative.count; i++) {
                const screen = relative.get(i);
                if (screen.name === root.monitor.name)
                    return screen;
            }
            return undefined;
        }
        property var contents: model.contents
        property var currentContent
        onContentsChanged: {
            if (!contents || !item || !root.monitor)
                return;
            return addContent();
        }
        onItemChanged: {
            if (!contents || !item || !root.monitor)
                return;
            return addContent();
        }

        function addContent() {
            const type = contents.type;

            if (containerloader.currentContent) {
                containerloader.currentContent.destroy();
            }
            switch (type) {
            case "image":
                const img = Components.createImage(contents.source, contents.kind, item);
                containerloader.currentContent = img;
                return;
            case "widget":
                const component = Qt.createComponent(contents.source);
                const incubator = component.incubateObject(containerloader.item, {});
                if (incubator.status !== Component.Ready) {
                    incubator.onStatusChanged = function (status) {
                        if (status === Component.Ready) {
                            const widget = incubator.object;
                            widget.parent = containerloader.item;
                            widget.anchors.fill = containerloader.item;
                            containerloader.currentContent = widget;
                            if (contents.props) {
                                widget.property.setProperty(contents.props);
                            }
                            widget.modal.connect((modal, hasChanges) => {
                                bottom.hasMenu = modal ? true : false;
                                if (modal) {
                                    modal.y = item.height;
                                    modal.x = (item.width - modal.width) / 2;
                                }
                                if (hasChanges) {
                                    const props = widget.property.getProperty();
                                    const conf = Wallpaper.containers.get(containerloader.index);
                                    const withProps = conf.contents;
                                    withProps.props = props;
                                    Wallpaper.containers.setProperty(containerloader.index, "contents", withProps);
                                    Wallpaper.containers.save();
                                }
                            });
                        }
                    };
                }
                return;
            default:
                return;
            }
        }

        active: (coords && root.monitor) || false

        component: Pane {
            parent: layered
            bg.color: "transparent"
            width: containerloader.model.width
            height: containerloader.model.height
            visible: containerloader.coords ? true : false
            x: containerloader.coords ? containerloader.coords.x : 0
            y: containerloader.coords ? containerloader.coords.y : 0
            z: containerloader.model.z
        }
    }

    DelegateModel {
        id: images
        model: Wallpaper.containers
        delegate: LazyContainer {}
    }

    Item {
        id: layered
        anchors.fill: parent
        Instantiator {
            model: images
            onObjectRemoved: (idx, obj) => {
                obj.destroy();
            }
        }
    }

    Label {
        id: clock
        property var date: new Date()

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: 100
        }

        // The native font renderer tends to look nicer at large sizes.
        renderType: Text.NativeRendering
        font.pointSize: 80
        color: Colors.color.primary
        // updates the clock every second
        Timer {
            running: true
            repeat: true
            interval: 1000

            onTriggered: clock.date = new Date()
        }

        // updated when the date changes
        text: {
            const hours = this.date.getHours().toString().padStart(2, '0');
            const minutes = this.date.getMinutes().toString().padStart(2, '0');
            return `${hours}:${minutes}`;
        }
    }

    ColumnLayout {
        id: background
        state: Window.active ? "show" : "hide"
        states: [
            State {
                name: "hide"
                PropertyChanges {
                    target: background
                    opacity: 0
                }
            },
            State {
                name: "show"
                PropertyChanges {
                    target: background
                    opacity: 1
                }
            }
        ]

        transitions: [
            Transition {
                from: "*"
                to: "*"
                NumberAnimation {
                    properties: "opacity"
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
                ColorAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }
        ]
        visible: Window.active

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.verticalCenter
        }

        RowLayout {
            TextField {
                id: passwordBox

                implicitWidth: 400
                padding: 10
                background: Rectangle {
                    anchors.fill: parent
                    border {
                        width: 2
                        color: Colors.color.outline
                    }
                    color: Colors.color.on_background
                }
                focus: true
                enabled: !root.context.unlockInProgress
                echoMode: TextInput.Password
                inputMethodHints: Qt.ImhSensitiveData

                // Update the text in the context when the text in the box changes.
                onTextChanged: root.context.currentText = this.text

                // Try to unlock when enter is pressed.
                onAccepted: root.context.tryUnlock()

                // Update the text in the box to match the text in the context.
                // This makes sure multiple monitors have the same text.
                Connections {
                    target: root.context

                    function onCurrentTextChanged() {
                        passwordBox.text = root.context.currentText;
                    }
                }
            }

            Button {
                text: "Unlock"
                padding: 10

                // don't steal focus from the text box
                focusPolicy: Qt.NoFocus

                enabled: !root.context.unlockInProgress && root.context.currentText !== ""
                onClicked: root.context.tryUnlock()
            }
        }

        Label {
            visible: root.context.showFailure
            text: "Incorrect password"
        }
    }
}
