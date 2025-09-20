import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire

import qs.assets

import Qt5Compat.GraphicalEffects

ShellRoot {
    Variants {
        model: Quickshell.screens
        PanelWindow {
            property var modelData
            screen: modelData
            color: 'transparent'
            FloatingWindow {
                maximumSize: Qt.size(modelData.width / 2, modelData.height / 2)
                minimumSize: Qt.size(modelData.width / 2, modelData.height / 2)
                color: "transparent"

                Rectangle {
                    id: root
                    readonly property ColorGroup colors: Window.active ? palette.active : palette.inactive
                    anchors.fill: parent
                    color: colors.window
                    property bool isPortrait: height > width

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
                                            text: currentCondition.icon
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
                                                text: currentCondition.weatherDesc
                                                font.bold: true
                                                horizontalAlignment: Text.AlignHCenter
                                                font.family: FontProvider.fontSometypeMono
                                                wrapMode: Text.Wrap
                                            }
                                            Text {
                                                Layout.fillWidth: true
                                                text: currentCondition.temp
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
                                            text: currentCondition.icon
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
                                                text: currentCondition.weatherDesc
                                                font.bold: true
                                                horizontalAlignment: Text.AlignHCenter
                                                font.family: FontProvider.fontSometypeMono
                                                wrapMode: Text.Wrap
                                            }
                                            Text {
                                                Layout.fillWidth: true
                                                text: currentCondition.temp
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

                    // ColumnLayout {
                    //     anchors {
                    //         horizontalCenter: parent.horizontalCenter
                    //         verticalCenter: parent.verticalCenter
                    //     }

                    //     Label {
                    //         id: clock
                    //         property var date: new Date()
                    //         renderType: Text.NativeRendering
                    //         font.pointSize: 80

                    //         // updates the clock every second
                    //         Timer {
                    //             running: true
                    //             repeat: true
                    //             interval: 1000

                    //             onTriggered: clock.date = new Date()
                    //         }

                    //         // updated when the date changes
                    //         text: {
                    //             const hours = this.date.getHours().toString().padStart(2, '0');
                    //             const minutes = this.date.getMinutes().toString().padStart(2, '0');
                    //             return `${hours}:${minutes}`;
                    //         }
                    //     }

                    //     RowLayout {
                    //         TextField {
                    //             id: passwordBox

                    //             implicitWidth: 400
                    //             padding: 10

                    //             focus: true
                    //             echoMode: TextInput.Password
                    //             inputMethodHints: Qt.ImhSensitiveData

                    //             // Update the text in the context when the text in the box changes.
                    //             onTextChanged: {}

                    //             // Try to unlock when enter is pressed.
                    //             onAccepted: {}
                    //         }

                    //         Button {
                    //             text: "Unlock"
                    //             padding: 10

                    //             // don't steal focus from the text box
                    //             focusPolicy: Qt.NoFocus
                    //         }
                    //     }

                    //     Label {
                    //         visible: true
                    //         text: "Incorrect password"
                    //     }
                    // }

                    ColumnLayout {
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            verticalCenter: parent.verticalCenter
                        }

                        Rectangle {
                            width: 400
                            height: 200
                        }
                    }
                }
            }
        }
    }

    property var currentCondition

    Component.onCompleted: {
        currentCondition = {
            weatherDesc: "Partly Cloudy",
            feelslike: "Feels like 22°C",
            temp: "69°C",
            icon: "\uf172",
            visibility: 10,
            pressure: 1013,
            humidity: 65,
            windSpeed: 15
        };
    }
}
