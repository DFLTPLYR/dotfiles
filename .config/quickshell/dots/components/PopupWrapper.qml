import QtQuick
import Quickshell

import qs.config

PopupWindow {
    id: root
    property bool shouldBeVisible: false
    property bool isPortrait: screen.height > screen.width
    property real animProgress: 0.0
    implicitWidth: 500
    implicitHeight: 500
    color: "white"
    signal hide
    visible: false

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
        if (animProgress > 0 && !visible)
            visible = true;
        if (!shouldBeVisible && Math.abs(animProgress) < 0.001) {
            visible = false;
            root.hide();
        }
    }
}
