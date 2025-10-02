import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Services.Greetd

import Quickshell.Io
import Quickshell.Wayland

import qs.assets
import qs.services
import Qt5Compat.GraphicalEffects
import QtQuick.Effects

ShellRoot {
    Variants {
        model: Quickshell.screens
        delegate: PanelWindow {
            id: root
            required property ShellScreen modelData
            screen: modelData
            property bool isPortrait: screen.height > screen.width
            property bool isLoading: true

            anchors {
                left: true
                bottom: true
                right: true
                top: true
            }

            color: Qt.rgba(0.33, 0.33, 0.41, 0.78)
            exclusiveZone: ExclusionMode.Ignore
            aboveWindows: false

            // blur per screen
            GaussianBlur {
                anchors.fill: parent
                radius: 20
                samples: 20

                source: Image {
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectCrop
                    source: WallpaperStore.currentWallpapers[screen.name] ?? null
                    cache: true
                    asynchronous: true
                    smooth: true
                }
            }

            // additional blur for sigma effect :D
            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0.33, 0.33, 0.41, 0.2)
            }

            // back shadow of the login ui
            RectangularShadow {
                anchors.fill: uiLogin
                offset.x: -10
                offset.y: -5
                radius: uiLogin.radius
                blur: 30
                spread: 10
                color: Qt.darker(uiLogin.color, 0.4)
            }

            // log in ui
            Rectangle {
                id: uiLogin
                anchors.centerIn: parent
                width: isPortrait ? screen.width / 2 : screen.width / 2.5
                height: screen.height / 2.5
                radius: 14
                layer.enabled: true
                color: Qt.rgba(0.72, 0.72, 0.76, 0.23)
                border.color: Qt.rgba(0.13, 0.13, 0.14, 0.31)
                // Items

                // ColumnLayout {
                //     anchors.fill: parent
                //     anchors.margins: 10

                //     Label {
                //         id: clock
                //         Layout.fillWidth: true
                //         Layout.preferredHeight: uiLogin.height / 6
                //         Layout.alignment: Qt.AlignHCenter

                //         horizontalAlignment: Text.AlignHCenter
                //         verticalAlignment: Text.AlignVCenter

                //         property var date: new Date()

                //         renderType: Text.NativeRendering
                //         font.pointSize: Math.round(Math.min(width, height))
                //         font.pixelSize: Math.round(height)
                //         font.weight: Font.Black
                //         font.family: FontProvider.fontSometypeMono
                //         font.bold: true
                //         color: ColorPalette.text
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

                //     ColumnLayout {
                //         Layout.fillWidth: true
                //         Layout.fillHeight: true
                //         Layout.alignment: Qt.AlignHCenter
                //         TextField {
                //             id: passwordBox

                //             implicitWidth: uiLogin.width * 0.75
                //             padding: 10

                //             focus: true
                //             enabled: true
                //             echoMode: TextInput.Password
                //             inputMethodHints: Qt.ImhSensitiveData
                //             horizontalAlignment: Text.AlignHCenter
                //             verticalAlignment: Text.AlignVCenter
                //             Material.accent: ColorPalette.primary
                //             // Update the text in the context when the text in the box changes.
                //             onTextChanged: root.context.currentText = this.text

                //             // Try to unlock when enter is pressed.
                //             onAccepted: {
                //                 return;
                //             }
                //         }

                //         Button {
                //             text: "Unlock"
                //             padding: 10
                //             Layout.alignment: Qt.AlignHCenter
                //             focusPolicy: Qt.NoFocus
                //             enabled: !root.context.unlockInProgress && root.context.currentText !== ""

                //             Material.background: ColorPalette.color12
                //             Material.foreground: ColorPalette.text
                //             Material.roundedScale: Material.ExtraSmallScale
                //             onClicked: {
                //                 return;
                //             }
                //         }
                //     }

                //     Label {
                //         id: errorLabel
                //         Layout.fillWidth: true
                //         Layout.preferredHeight: uiLogin.height / 8
                //         Layout.alignment: Qt.AlignHCenter
                //         visible: true

                //         renderType: Text.NativeRendering
                //         horizontalAlignment: Text.AlignHCenter
                //         verticalAlignment: Text.AlignVCenter

                //         wrapMode: Text.Wrap

                //         font.pointSize: Math.round(Math.min(width, height))
                //         font.pixelSize: Math.round(height * 0.5)
                //         font.weight: Font.Black
                //         font.family: FontProvider.fontSometypeMono
                //         font.bold: true
                //         color: ColorPalette.color15
                //     }
                // }

                Canvas {
                    id: ecgCanvas
                    width: 600
                    height: 200
                    property var data: (function () {
                            var arr = [];
                            for (var i = 0; i < ecgCanvas.width; i++)
                                arr.push(ecgCanvas.height / 2);
                            return arr;
                        })()

                    Timer {
                        interval: 30
                        running: true
                        repeat: true
                        onTriggered: {
                            var arr = ecgCanvas.data.slice(); // clone array
                            var newVal = ecgCanvas.height / 2 + Math.random() * 10 - 5;

                            // simulate occasional ECG spikes
                            if (Math.random() < 0.02)
                                newVal = ecgCanvas.height / 4;
                            if (Math.random() < 0.01)
                                newVal = ecgCanvas.height * 0.75;

                            arr.push(newVal); // add new sample to right
                            arr.shift(); // remove oldest sample (left)
                            ecgCanvas.data = arr;
                            ecgCanvas.requestPaint();
                        }
                    }

                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.clearRect(0, 0, width, height);
                        ctx.beginPath();
                        ctx.moveTo(0, data[0]);
                        for (var i = 1; i < data.length; i++) {
                            ctx.lineTo(i, data[i]);
                        }
                        ctx.strokeStyle = "lime";
                        ctx.lineWidth = 2;
                        ctx.stroke();
                    }
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
    }
}
