import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import qs.services
import QtQuick.Controls

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
}
