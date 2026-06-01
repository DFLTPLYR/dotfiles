import QtQuick
import QtQuick.Controls.Basic
import qs.core

Popup {
    id: popup

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
    focus: true

    background: Rectangle {
        id: background

        color: Colors.setOpacity(Colors.color.background, 0.6)
        border.color: Colors.color.outline
        Component.onCompleted: {
            Global.bindRadii(background);
        }
    }
}
