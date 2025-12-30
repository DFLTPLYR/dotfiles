pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire

import qs.services
import qs.assets
import qs.components

import qs.config

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
        active: root.shouldShowOsd
        component: PanelWindow {
            id: rootWindow

            implicitWidth: screen.width
            implicitHeight: screen.height

            color: "transparent"

            mask: Region {
                item: volumeSlider
            }

            property bool isPortrait: screen.height > screen.width

            property string volumeIcon: Math.round(root.volume * 100) > 0 ? (Math.round(root.volume * 100) < 70 ? '\uf027' : '\uf028') : '\uf026'

            Item {
                id: mainrect

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 40

                implicitWidth: isPortrait ? parent.width * 0.3 : parent.width / 6
                implicitHeight: 40

                NumberAnimation on opacity {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }

                NumberAnimation on y {
                    duration: 300
                    easing.type: Easing.OutCubic
                }

                StyledRect {
                    childContainerHeight: parent.height

                    RowLayout {
                        id: layout
                        anchors.fill: parent
                        anchors.margins: 10

                        Text {
                            Layout.preferredWidth: 60
                            text: `${volumeIcon}   ${Math.round(root.volume * 100)}%`
                            color: Color.color13
                            elide: Text.ElideRight
                            clip: true
                            font.family: FontProvider.fontAwesomeRegular
                            font.pixelSize: 14
                        }

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
                                color: Color.color1

                                Rectangle {
                                    width: volumeSlider.visualPosition * (volumeSlider.width - volumeSlider.handleSize) + volumeSlider.handleSize / 2
                                    height: parent.height
                                    radius: 5
                                    color: Color.color13
                                }
                            }

                            handle: Rectangle {
                                width: volumeSlider.handleSize * 1.25
                                height: volumeSlider.handleSize * 1.25
                                radius: volumeSlider.handleSize
                                color: Color.color13
                                border.color: Color.color12

                                y: (volumeSlider.height - height) / 2
                                x: volumeSlider.visualPosition * (volumeSlider.width - width)
                            }
                        }
                    }
                }
            }

            Component.onCompleted: {
                if (this.WlrLayershell != null) {
                    this.WlrLayershell.layer = WlrLayer.Overlay;
                }
            }
        }
    }
}
