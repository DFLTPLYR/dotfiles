import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import Quickshell.Wayland
import Quickshell

import qs.utils
import qs.assets
import qs.services
import qs.components

Rectangle {
    id: root
    required property LockContext context
    required property ShellScreen contextScreen
    readonly property ColorGroup colors: Window.active ? palette.active : palette.inactive

    property bool isLoading: true

    Material.theme: Material.Dark
    Material.accent: Material.Purple

    color: colors.window

    property bool isPortrait: height > width

    Image {
        id: backgroundImage
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        cache: true
        asynchronous: true
        smooth: true
        visible: true
    }

    Item {
        width: Math.max(200, root.width / 6)
        height: root.height / 4

        Rectangle {
            anchors.fill: parent
            anchors.margins: 10
            radius: 8
            layer.enabled: true
            layer.smooth: true

            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: Qt.rgba(1, 1, 1, 0.06)
                }
                GradientStop {
                    position: 1.0
                    color: Qt.rgba(1, 1, 1, 0.02)
                }
            }

            border.color: Qt.rgba(1, 1, 1, 0.08)

            Component {
                id: landscape
                RowLayout {
                    anchors.fill: parent

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        RoundButton {
                            anchors.fill: parent
                            anchors.margins: 10
                            font.pixelSize: width
                            text: root.isLoading ? "" : WeatherFetcher.currentCondition?.icon
                            font.family: FontProvider.fontMaterialOutlined
                            background: Rectangle {
                                anchors.fill: parent
                                color: "transparent"
                            }
                        }
                    }
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 2
                            Text {
                                Layout.fillWidth: true
                                text: root.isLoading ? "" : WeatherFetcher.currentCondition?.weatherDesc
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                font.family: FontProvider.fontSometypeMono
                                wrapMode: Text.Wrap
                            }
                            Text {
                                Layout.fillWidth: true
                                text: root.isLoading ? "" : WeatherFetcher.currentCondition?.temp
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                font.family: FontProvider.fontSometypeMono
                                wrapMode: Text.Wrap
                            }
                        }
                    }
                }
            }

            Component {
                id: portrait
                ColumnLayout {
                    anchors.fill: parent

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        RoundButton {
                            anchors.fill: parent
                            anchors.margins: 10
                            font.pixelSize: height
                            text: root.isLoading ? "" : WeatherFetcher.currentCondition?.icon
                            font.family: FontProvider.fontMaterialOutlined
                            background: Rectangle {
                                anchors.fill: parent
                                color: "transparent"
                            }
                        }
                    }
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 2
                            Text {
                                Layout.fillWidth: true
                                text: root.isLoading ? "" : WeatherFetcher.currentCondition?.weatherDesc
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                font.family: FontProvider.fontSometypeMono
                                wrapMode: Text.Wrap
                            }
                            Text {
                                Layout.fillWidth: true
                                text: root.isLoading ? "" : WeatherFetcher.currentCondition?.temp
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                font.family: FontProvider.fontSometypeMono
                                wrapMode: Text.Wrap
                            }
                        }
                    }
                }
            }

            Loader {
                anchors.fill: parent
                sourceComponent: root.isPortrait ? portrait : landscape
            }
        }
    }

    Button {
        text: "Its not working, let me out"
        onClicked: context.unlocked()
    }

    ColumnLayout {
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }

        Label {
            id: clock
            anchors.horizontalCenter: parent.horizontalCenter

            property var date: new Date()
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
                anchors.horizontalCenter: parent.horizontalCenter
                // don't steal focus from the text box
                focusPolicy: Qt.NoFocus

                enabled: !root.context.unlockInProgress && root.context.currentText !== ""
                onClicked: root.context.tryUnlock()
            }
        }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: root.context.showFailure
            text: "Incorrect password"
        }
    }

    Connections {
        target: root
        function onContextScreenChanged() {
            if (root.contextScreen)
                backgroundImage.source = WallpaperStore.currentWallpapers[root.contextScreen.name];
        }
    }

    Connections {
        target: WeatherFetcher
        function onParseDone() {
            root.isLoading = false;
        }
    }

    Component.onCompleted: {
        root.isLoading = typeof WeatherFetcher.currentCondition === 'undefined';
    }
}
