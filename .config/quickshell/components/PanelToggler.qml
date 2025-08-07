// LottieToggleButton.qml
import QtQuick
import QtQuick.Controls
import Qt.labs.lottieqt
import qs.services

RoundButton {
    id: root

    implicitHeight: parent ? parent.height : 48
    implicitWidth: implicitHeight

    // Exposed properties for reusability
    property alias source: anim.source
    property bool active: false

    // Custom signal - named to avoid conflicts and be descriptive
    signal activationChanged(bool isActive)

    background: Rectangle {
        anchors.fill: parent
        color: Colors.color2
        opacity: 0.4
        radius: parent.radius
        anchors.margins: 2
    }

    contentItem: Item {
        anchors.fill: parent

        LottieAnimation {
            id: anim
            anchors.centerIn: parent
            scale: 0.5
            autoPlay: false
            loops: 1
            quality: LottieAnimation.MediumQuality
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onEntered: {
            anim.direction = LottieAnimation.Forward;
            anim.start();
        }

        onExited: {
            // anim.direction = LottieAnimation.Backward;
            anim.start();
        }

        onClicked: {
            active = !active;
            activationChanged(root.active);
        }
    }

    Component.onCompleted: anim.play()
}
