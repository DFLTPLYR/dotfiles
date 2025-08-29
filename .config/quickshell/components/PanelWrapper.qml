import QtQuick
import Quickshell
import Quickshell.Hyprland

PanelWindow {
    screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? null

    color: 'transparent'

    readonly property bool isPortrait: screen.height > screen.width

    // Internal properties
    property bool shouldBeVisible: false
    property bool internalVisible: false
    property real animProgress: 0.0

    // Signals for custom behavior
    signal hidden(string drawerKey)
    signal visibilityChanged(bool value, string monitorName)

    visible: internalVisible
    focusable: internalVisible

    // Manual animator
    NumberAnimation on animProgress {
        id: anim
        duration: 300
        easing.type: Easing.InOutQuad
    }

    onShouldBeVisibleChanged: {
        const target = shouldBeVisible ? 1.0 : 0.0;
        if (anim.to !== target || !anim.running) {
            anim.to = target;
            anim.restart();
        }
    }

    onAnimProgressChanged: {
        if (animProgress > 0 && !internalVisible) {
            internalVisible = true;
        } else if (!shouldBeVisible && animProgress === 0.00) {
            internalVisible = false;
            root.isVisible = false;
        }
    }

    onScreenChanged: {
        const target = shouldBeVisible ? 1.0 : 0.0;
        anim.stop();
        animProgress = target === 1.0 ? 0.0 : 1.0;
        anim.to = target;
        Qt.callLater(function () {
            anim.restart();
        });
    }

    // set up
    Component.onCompleted: {
        if (this.WlrLayershell != null) {
            this.WlrLayershell.layer = WlrLayer.Overlay;
            this.exclusiveZone = 0;
        }
    }
}
