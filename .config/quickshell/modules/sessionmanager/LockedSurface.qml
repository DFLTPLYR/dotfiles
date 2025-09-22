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
    property bool showError: context.showFailure

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

            color: Qt.rgba(0.03, 0.02, 0.02, 0.56)
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
                            font.pixelSize: Math.min(width, height)
                            text: root.isLoading ? "" : WeatherFetcher.currentCondition?.icon
                            font.family: FontProvider.fontMaterialOutlined

                            background: Rectangle {
                                anchors.fill: parent
                                color: "transparent"
                            }

                            contentItem: Text {
                                text: parent.text
                                color: ColorPalette.color14
                                font: parent.font
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: context.unlocked()
                        }
                    }
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 2

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Text {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    font.pixelSize: Math.min(width, height) * 0.5
                                    font.bold: true
                                    text: root.isLoading ? "" : WeatherFetcher.currentCondition?.weatherDesc
                                    Layout.alignment: Qt.AlignHCenter
                                    font.family: FontProvider.fontSometypeMono
                                    wrapMode: Text.Wrap
                                    color: ColorPalette.color15
                                }
                            }
                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Text {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    font.pixelSize: Math.min(width, height) * 0.5
                                    font.bold: true
                                    text: root.isLoading ? "" : WeatherFetcher.currentCondition?.temp
                                    Layout.alignment: Qt.AlignHCenter
                                    font.family: FontProvider.fontSometypeMono
                                    wrapMode: Text.Wrap
                                    color: ColorPalette.color15
                                }
                            }
                        }
                    }
                }
            }

            Component {
                id: landscapeLoading
                RowLayout {
                    anchors.fill: parent

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        RoundButton {
                            anchors.fill: parent
                            anchors.margins: 10
                            font.pixelSize: Math.min(width, height)
                            text: "\ue86a"
                            font.family: FontProvider.fontMaterialRounded

                            background: Rectangle {
                                anchors.fill: parent
                                color: "transparent"
                            }

                            contentItem: Text {
                                text: parent.text
                                color: ColorPalette.color10
                                font: parent.font
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

                            onClicked: context.unlocked()
                        }
                    }
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 2

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Text {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    font.pixelSize: Math.min(width, height) * 0.5
                                    font.bold: true
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "\ue86a"
                                    font.family: FontProvider.fontMaterialRounded
                                    wrapMode: Text.Wrap
                                    color: ColorPalette.color15
                                }
                            }
                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Text {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    font.pixelSize: Math.min(width, height) * 0.5
                                    font.bold: true
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "\ue86a"
                                    font.family: FontProvider.fontMaterialRounded
                                    wrapMode: Text.Wrap
                                    color: ColorPalette.color15
                                }
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
                            font.pixelSize: Math.min(width, height)
                            text: root.isLoading ? "" : WeatherFetcher.currentCondition?.icon
                            font.family: FontProvider.fontMaterialOutlined

                            background: Rectangle {
                                anchors.fill: parent
                                color: "transparent"
                            }

                            contentItem: Text {
                                text: parent.text
                                color: ColorPalette.color14
                                font: parent.font
                                Layout.alignment: Qt.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: context.unlocked()
                        }
                    }
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 2
                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Text {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    font.pixelSize: Math.min(width, height) * 0.5
                                    font.bold: true
                                    text: root.isLoading ? "" : WeatherFetcher.currentCondition?.weatherDesc
                                    Layout.alignment: Qt.AlignHCenter
                                    font.family: FontProvider.fontSometypeMono
                                    wrapMode: Text.Wrap
                                    color: ColorPalette.color15
                                }
                            }
                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Text {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    font.pixelSize: Math.min(width, height) * 0.5
                                    font.bold: true
                                    text: root.isLoading ? "" : WeatherFetcher.currentCondition?.temp
                                    Layout.alignment: Qt.AlignHCenter
                                    font.family: FontProvider.fontSometypeMono
                                    wrapMode: Text.Wrap
                                    color: ColorPalette.color15
                                }
                            }
                        }
                    }
                }
            }

            Component {
                id: portraitLoading
                ColumnLayout {
                    anchors.fill: parent

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        RoundButton {
                            anchors.fill: parent
                            anchors.margins: 10
                            font.pixelSize: Math.min(width, height)
                            text: "\ue86a"
                            font.family: FontProvider.fontMaterialOutlined

                            background: Rectangle {
                                anchors.fill: parent
                                color: "transparent"
                            }

                            contentItem: Text {
                                text: parent.text
                                color: ColorPalette.color10
                                font: parent.font
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

                            onClicked: context.unlocked()
                        }
                    }
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 2
                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Text {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    font.pixelSize: Math.min(width, height) * 0.5
                                    font.bold: true
                                    text: root.isLoading ? "" : WeatherFetcher.currentCondition?.weatherDesc
                                    Layout.alignment: Qt.AlignHCenter
                                    font.family: FontProvider.fontSometypeMono
                                    wrapMode: Text.Wrap
                                    color: ColorPalette.color15
                                }
                            }
                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Text {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    font.pixelSize: Math.min(width, height) * 0.5
                                    font.bold: true
                                    text: root.isLoading ? "" : WeatherFetcher.currentCondition?.temp
                                    Layout.alignment: Qt.AlignHCenter
                                    font.family: FontProvider.fontSometypeMono
                                    wrapMode: Text.Wrap
                                    color: ColorPalette.color15
                                }
                            }
                        }
                    }
                }
            }

            Loader {
                anchors.fill: parent
                sourceComponent: root.isPortrait ? (root.isLoading ? portraitLoading : portrait) : (root.isLoading ? landscapeLoading : landscape)
            }
        }
    }

    Item {
        anchors.fill: parent
        ColumnLayout {
            anchors.centerIn: parent

            Label {
                id: clock
                Layout.alignment: Qt.AlignHCenter

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
                Layout.alignment: Qt.AlignHCenter
                visible: root.context.showFailure
                font.pointSize: 12
                renderType: Text.NativeRendering
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
