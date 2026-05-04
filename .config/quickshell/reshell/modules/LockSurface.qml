import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

import qs.core
import qs.components

Rectangle {
    id: root
    required property LockContext context
    readonly property ColorGroup colors: Window.active ? palette.active : palette.inactive
    required property ShellScreen monitor
    color: colors.window

    component LazyImage: LazyLoader {
        id: imageloader
        required property int index
        required property var model
        property var relative: model.screens
        property var coords

        active: coords
        onRelativeChanged: {
            if (!relative || !relative.count)
                return;
            for (let i = 0; i < relative.count; i++) {
                const screen = relative.get(i);
                if (screen.name === panel.screen.name) {
                    return coords = screen;
                }
            }
        }

        component: Image {
            parent: layered

            width: imageloader.model.width
            height: imageloader.model.height
            visible: imageloader.coords ? true : false
            x: imageloader.coords ? imageloader.coords.x : 0
            y: imageloader.coords ? imageloader.coords.y : 0
            z: imageloader.model.z

            source: imageloader.model.source
        }
    }

    DelegateModel {
        id: images
        model: Wallpaper.list
        delegate: LazyImage {}
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
