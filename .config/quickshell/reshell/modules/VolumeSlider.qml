import Quickshell
import QtQuick

import Quickshell.Services.Pipewire

import qs.core
import qs.components

Item {
    id: scope
    property bool shouldShowOsd: false
    property real volume: Pipewire.defaultAudioSink?.audio.volume ?? 0

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    Connections {
        target: Pipewire?.defaultAudioSink?.audio || null
        function onVolumeChanged() {
            scope.shouldShowOsd = true;
            hideTimer.restart();
            scope.volume = Pipewire.defaultAudioSink?.audio.volume ?? 0;
        }
    }

    Timer {
        id: hideTimer
        interval: 1000
        onTriggered: scope.shouldShowOsd = false
    }

    Behavior on volume {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    LazyLoader {
        id: volumeSliderLoader
        active: scope.shouldShowOsd
        component: Slider {
            parent: scope
            visible: scope.shouldShowOsd && Compositor.focusedMonitor === screen.name
            opacity: scope.shouldShowOsd ? 1 : 0
            width: 300
            from: 0
            to: 1
            value: Pipewire.defaultAudioSink?.audio.volume ?? 0
            stepSize: 0.01
            x: screen.width / 2 - width / 2

            hoverEnabled: true

            onActiveFocusChanged: {
                if (!activeFocus)
                    hideTimer.start();
            }

            onHoveredChanged: {
                if (hovered) {
                    scope.shouldShowOsd = true;
                    hideTimer.stop();
                } else {
                    hideTimer.start();
                }
            }

            onValueChanged: {
                if (Pipewire.defaultAudioSink?.audio) {
                    Pipewire.defaultAudioSink.audio.volume = value;
                }
                scope.volume = value;
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }
}
