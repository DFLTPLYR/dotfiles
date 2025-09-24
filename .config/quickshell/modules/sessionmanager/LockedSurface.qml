import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import Quickshell
import Quickshell.Wayland

import QtQuick.Effects
import Qt5Compat.GraphicalEffects

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
    property bool showError: context.showFailure

    Material.theme: Material.Dark
    Material.accent: Material.Purple

    color: colors.window

    property bool isPortrait: height > width

    // blur per screen
    GaussianBlur {
        anchors.fill: parent
        radius: 20
        samples: 20

        source: Image {
            id: backgroundImage
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            cache: true
            asynchronous: true
            smooth: true
            visible: true
        }
    }

    // additional blur for sigma effect :D
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0.33, 0.33, 0.41, 0.2)
    }

    // Weather widget
    Item {
        width: 300
        height: Math.min(150, root.isPortrait ? root.height / 4 : root.height / 2)

        // Background
        Rectangle {
            anchors.fill: parent
            anchors.margins: 10
            radius: 10
            color: Qt.rgba(0.72, 0.72, 0.76, 0.23)
            border.color: Qt.rgba(0.13, 0.13, 0.14, 0.31)

            Component {
                id: loadingWidgetWeather
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Text {
                            anchors.centerIn: parent
                            text: "\ue86a"
                            font.family: FontProvider.fontMaterialRounded
                            font.pixelSize: Math.min(parent.width, parent.height)
                            RotationAnimation on rotation {
                                from: 0
                                to: 360
                                duration: 3000
                                loops: Animation.Infinite
                                running: isLoading
                            }
                        }
                    }
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 10
                            Text {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignBottom
                                text: "\ue86a"
                                font.family: FontProvider.fontMaterialRounded
                                wrapMode: Text.Wrap
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter

                                RotationAnimation on rotation {
                                    from: 0
                                    to: 360
                                    duration: 3000
                                    loops: Animation.Infinite
                                    running: isLoading
                                }
                            }
                            Text {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignTop
                                text: "\ue86a"
                                font.family: FontProvider.fontMaterialRounded
                                wrapMode: Text.Wrap
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter

                                RotationAnimation on rotation {
                                    from: 0
                                    to: 360
                                    duration: 3000
                                    loops: Animation.Infinite
                                    running: isLoading
                                }
                            }
                        }
                    }
                }
            }

            Component {
                id: activeWidgetWeather
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Text {
                            anchors.centerIn: parent
                            text: root.isLoading ? "" : WeatherFetcher.currentCondition?.icon
                            font.family: FontProvider.fontMaterialRounded
                            font.pixelSize: Math.min(parent.width, parent.height)

                            MouseArea {
                                anchors.fill: parent
                                onClicked: console.log('test')
                            }
                        }
                    }
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 10
                            Text {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignBottom
                                text: root.isLoading ? "" : WeatherFetcher.currentCondition?.weatherDesc
                                font.family: FontProvider.fontSometypeMono
                                wrapMode: Text.Wrap
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            Text {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignTop
                                text: root.isLoading ? "" : WeatherFetcher.currentCondition?.temp
                                font.family: FontProvider.fontSometypeMono
                                wrapMode: Text.Wrap
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }
            }

            Loader {
                anchors.fill: parent
                sourceComponent: isLoading ? loadingWidgetWeather : activeWidgetWeather
            }
        }
    }

    // log in ui
    Rectangle {
        id: uiLogin
        anchors.centerIn: parent
        width: isPortrait ? screen.width / 2 : screen.width / 2
        height: isPortrait ? screen.height / 2.5 : screen.height / 2
        radius: 14
        layer.enabled: true
        color: Qt.rgba(0.72, 0.72, 0.76, 0.23)
        border.color: Qt.rgba(0.13, 0.13, 0.14, 0.31)

        // Items

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10

            Label {
                id: clock
                Layout.fillWidth: true
                Layout.preferredHeight: uiLogin.height / 6
                Layout.alignment: Qt.AlignHCenter

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                property var date: new Date()

                renderType: Text.NativeRendering
                font.pointSize: 24

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
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignHCenter
                TextField {
                    id: passwordBox

                    implicitWidth: 400
                    padding: 10

                    focus: true
                    enabled: !root.context.unlockInProgress
                    echoMode: TextInput.Password
                    inputMethodHints: Qt.ImhSensitiveData
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
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
                    Layout.alignment: Qt.AlignHCenter
                    // don't steal focus from the text box
                    focusPolicy: Qt.NoFocus

                    enabled: !root.context.unlockInProgress && root.context.currentText !== ""
                    onClicked: root.context.tryUnlock()
                }
            }

            Label {
                id: errorLabel
                Layout.fillWidth: true
                Layout.preferredHeight: uiLogin.height / 8
                Layout.alignment: Qt.AlignHCenter
                visible: true
                font.pointSize: 12
                renderType: Text.NativeRendering
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    onShowErrorChanged: {
        var errorMessages = ["Tanga amputa di alam password", "Try bewbs69420", "try... 6...7", "Skill Issue try mo magMemoplus gold", "Maybe Start Digging in Yo Butt Twin", "Lesson Learned Kill yourself... litterally", "01 just called... they hit the second tower", "What are you, stupidmaxxing?", "clown school called, they'll be awarding you valedictorian"];
        errorLabel.text = errorMessages[Math.floor(Math.random() * errorMessages.length)];
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
