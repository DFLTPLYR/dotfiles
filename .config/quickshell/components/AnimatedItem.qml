import QtQuick

Item {
    // Internal animation state
    property real animationProgress: 0.0
    property bool shouldBeVisible: false
    property bool internalVisible: false

    signal hide

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
            root.hide();
        }
    }
}
