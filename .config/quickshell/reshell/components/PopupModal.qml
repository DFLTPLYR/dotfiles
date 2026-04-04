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
        anchors.fill: parent
        color: Colors.setOpacity(Colors.color.background, 0.5)
        border {
            width: 2
            color: Colors.color.outline
        }
        clip: true
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
