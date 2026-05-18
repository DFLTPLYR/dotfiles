import QtQuick
import Quickshell
import qs.config

PanelWindow {
    readonly property bool isPortrait: screen.height > screen.width
    // Internal properties
    property bool shouldBeVisible: false
    property bool internalVisible: false
    property real animProgress: 0

    // Signals for custom behavior
    signal hidden()

    screen: Quickshell.screens.find((s) => {
        return s.name === Config.focusedMonitor;
    })
    color: 'transparent'
    visible: internalVisible
    focusable: internalVisible
    onShouldBeVisibleChanged: {
        const target = shouldBeVisible ? 1 : 0;
        if (anim.to !== target || !anim.running) {
            anim.to = target;
            anim.restart();
        }
    }
    onAnimProgressChanged: {
        if (animProgress > 0 && !internalVisible) {
            internalVisible = true;
        } else if (!shouldBeVisible && animProgress === 0) {
            internalVisible = false;
            hidden();
        }
    }
    onScreenChanged: {
        const target = shouldBeVisible ? 1 : 0;
        anim.stop();
        animProgress = target === 1 ? 0 : 1;
        anim.to = target;
        Qt.callLater(function() {
            anim.restart();
        });
    }

    // Manual animator
    NumberAnimation on animProgress {
        id: anim

        duration: 300
        easing.type: Easing.InOutQuad
    }

}
