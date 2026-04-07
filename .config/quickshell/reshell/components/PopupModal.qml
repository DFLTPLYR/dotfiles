import QtQuick
import qs.core

Popup {
    id: modalPopup

    // margins
    rightMargin: 0
    leftMargin: 0
    bottomMargin: 0
    topMargin: 0

    // padding
    topPadding: 2
    bottomPadding: 2
    rightPadding: 2
    leftPadding: 2

    background: Rectangle {
        id: background
        anchors.fill: parent
        color: Colors.setOpacity(Colors.color.background, 0.9)

        border {
            width: 2
            color: Colors.color.outline
        }

        clip: true
    }

    transformOrigin: Item.Center

    enter: Transition {
        NumberAnimation {
            target: background
            property: "opacity"
            from: 0.0
            to: 1.0
            duration: 0
            easing.type: Easing.InOutQuad
        }
    }

    exit: Transition {
        NumberAnimation {
            target: background
            property: "opacity"
            from: 1.0
            to: 0.0
            duration: 0
            easing.type: Easing.InQuad
        }
    }

    onOpenedChanged: {
        if (!opened) {
            Global.modal = null;
            return;
        }
        if (Global.modal)
            Global.modal.close();

        Global.modal = modalPopup;
    }

    Connections {
        target: Global
        function onEditChanged() {
            if (modalPopup.opened) {
                modalPopup.close();
            }
        }
    }
}
