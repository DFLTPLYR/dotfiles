import QtQuick
import QtQuick.Controls.Basic
import qs.core

Popup {
    id: popup
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
    focus: true

    background: Rectangle {
        id: background
        anchors.fill: parent
        color: Colors.setOpacity(Colors.theme.surface, 0.6)
        border.color: Colors.theme.outline
        Component.onCompleted: {
            Utils.bindRadii(background);
        }
    }
}
