import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire

import qs.components

Scope {
    id: root

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    Connections {
        target: Pipewire?.defaultAudioSink?.audio || null
        function onVolumeChanged() {
            root.shouldShowOsd = true;
            hideTimer.restart();
            root.volume = Pipewire.defaultAudioSink?.audio.volume ?? 0;
        }
    }

    property bool shouldShowOsd: false
    property real volume: Pipewire.defaultAudioSink?.audio.volume ?? 0

    Timer {
        id: hideTimer
        interval: 1000
        onTriggered: root.shouldShowOsd = false
    }

    Behavior on volume {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    LazyLoader {
        id: overlayLoader
        active: root.shouldShowOsd
        component: PanelWindow {
            id: screenRoot

            implicitWidth: screen.width
            implicitHeight: screen.height

            readonly property bool isPortrait: screen.height >= screen.width

            color: "transparent"

            mask: Region {
                item: volumeSlider
            }

            Item {
                width: screenRoot.isPortrait ? screen.width * 0.4 : screenRoot.width * 0.2
                height: 50

                opacity: root.shouldShowOsd ? 1 : 0

                x: screenRoot.width / 2 - width / 2

                NumberAnimation on opacity {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }

                NumberAnimation on y {
                    duration: 300
                    easing.type: Easing.OutCubic
                }

                RowLayout {
                    id: layout
                    anchors.fill: parent
                    anchors.margins: 10

                    Slider {
                        id: volumeSlider
                        property real handleSize: 14

                        from: 0
                        to: 1
                        value: Pipewire.defaultAudioSink?.audio.volume ?? 0
                        stepSize: 0.01
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter

                        hoverEnabled: true

                        onActiveFocusChanged: {
                            if (!activeFocus)
                                hideTimer.start();
                        }

                        onHoveredChanged: {
                            if (hovered) {
                                root.shouldShowOsd = true;
                                hideTimer.stop();
                            } else {
                                hideTimer.start();
                            }
                        }

                        onValueChanged: {
                            if (Pipewire.defaultAudioSink?.audio) {
                                Pipewire.defaultAudioSink.audio.volume = value;
                            }
                            root.volume = value;
                        }

                        background: Rectangle {
                            implicitHeight: 10
                            radius: 5
                            color: Qt.rgba(1, 1, 1, 0.3)

                            Rectangle {
                                width: volumeSlider.visualPosition * (volumeSlider.width - volumeSlider.handleSize) + volumeSlider.handleSize / 2
                                height: parent.height
                                radius: 5
                                color: Qt.rgba(1, 1, 1, 0.8)
                            }
                        }

                        handle: Rectangle {
                            width: volumeSlider.handleSize * 1.25
                            height: volumeSlider.handleSize * 1.25
                            radius: volumeSlider.handleSize
                            color: Qt.rgba(1, 1, 1, 0.8)
                            border.color: Qt.rgba(1, 1, 1, 0.5)

                            y: (volumeSlider.height - height) / 2
                            x: volumeSlider.visualPosition * (volumeSlider.width - width)
                        }
                    }
                }
            }

            Component.onCompleted: {
                if (this.WlrLayershell) {
                    this.WlrLayershell.layer = WlrLayer.Overlay;
                }
            }
        }
    }
}
