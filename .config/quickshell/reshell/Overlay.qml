import QtQuick

import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire

import qs.modules
import qs.components

Variants {
    model: Quickshell.screens
    delegate: PanelWindow {
        id: panel
        required property ShellScreen modelData
        property bool shouldShowOsd: false
        property real volume: Pipewire.defaultAudioSink?.audio.volume ?? 0

        screen: modelData

        color: "transparent"

        implicitHeight: screen.height
        implicitWidth: screen.width

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: `Overlay-${screen.name}`

        PwObjectTracker {
            objects: [Pipewire.defaultAudioSink]
        }

        Connections {
            target: Pipewire?.defaultAudioSink?.audio || null
            function onVolumeChanged() {
                panel.shouldShowOsd = true;
                hideTimer.restart();
                panel.volume = Pipewire.defaultAudioSink?.audio.volume ?? 0;
            }
        }

        Timer {
            id: hideTimer
            interval: 1000
            onTriggered: panel.shouldShowOsd = false
        }

        Behavior on volume {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        mask: Region {
            regions: [
                Region {
                    item: volume
                }
            ]
        }

        Notifications {
            id: notification
            width: 400
            height: panel.height
            x: (panel.width * 1) - width
        }

        Slider {
            id: volume
            opacity: panel.shouldShowOsd
            from: 0
            to: 1
            value: Pipewire.defaultAudioSink?.audio.volume ?? 0
            stepSize: 0.01
            x: panel.width / 2 - width / 2

            hoverEnabled: true

            onActiveFocusChanged: {
                if (!activeFocus)
                    hideTimer.start();
            }

            onHoveredChanged: {
                if (hovered) {
                    panel.shouldShowOsd = true;
                    hideTimer.stop();
                } else {
                    hideTimer.start();
                }
            }

            onValueChanged: {
                if (Pipewire.defaultAudioSink?.audio) {
                    Pipewire.defaultAudioSink.audio.volume = value;
                }
                panel.volume = value;
            }
        }
    }
}
