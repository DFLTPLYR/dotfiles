// AnimatedPopup.qml
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets

PopupWindow {
    id: root
    visible: internalVisible
    color: "transparent"

    // Public API
    property alias contentItem: popupContent
    property bool shouldBeVisible: false
    property real maxWidth: 400
    property real maxHeight: 300

    // Internal animation state
    property real animProgress: 0.0
    property bool internalVisible: false

    // Animate scale/opacity
    Behavior on animProgress {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutCubic
        }
    }

    onAnimProgressChanged: {
        if (animProgress > 0 && !internalVisible)
            internalVisible = true;
        if (!shouldBeVisible && animProgress < 0.01)
            internalVisible = false;
    }

    Item {
        id: popupContent
        anchors.centerIn: parent
        width: maxWidth * animProgress
        height: maxHeight * animProgress
        scale: animProgress
        opacity: animProgress
        clip: true
        transformOrigin: Item.Center

        Behavior on width {
            NumberAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }
        Behavior on height {
            NumberAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }
        Behavior on scale {
            NumberAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }
    }

    // Sync animation state with toggle
    Component.onCompleted: {animProgress = shouldBeVisible ? 1 : 0}
    onShouldBeVisibleChanged: animProgress = shouldBeVisible ? 1 : 0
}
