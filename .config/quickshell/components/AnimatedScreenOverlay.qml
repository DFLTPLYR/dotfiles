import QtQuick
import QtQuick.Controls

import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

PanelWindow {
    id: root

    required property var screen
    required property string key

    property string drawerKey: `${key}-${screen.name}`
    property color backgroundColor: "black"

    // Internal properties
    property bool shouldBeVisible: false
    property bool internalVisible: false
    property real animProgress: 0.0

    // Signals for custom behavior
    signal hidden(string drawerKey)
    signal visibilityChanged(bool value, string monitorName)

    // Set screen and dimensions
    screen: screen

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    color: backgroundColor
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
            root.hidden(root.drawerKey);
        }
    }

    // Signal for mouse click events
    signal clicked

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
    }

    // Configure WlrLayershell if available
    Component.onCompleted: {
        if (this.WlrLayershell) {
            this.WlrLayershell.layer = WlrLayer.Overlay;
            this.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive;
            this.exclusionMode = ExclusionMode.Ignore;
        }
    }
}
