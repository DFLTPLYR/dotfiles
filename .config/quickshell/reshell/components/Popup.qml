import QtQuick
import QtQuick.Controls.Basic
import qs.core

Popup {
    id: popup
    background: Rectangle {
        implicitWidth: popup.width
        implicitHeight: popup.height
        color: Colors.setOpacity(Colors.color.background, 0.6)
        border.color: Colors.color.outline
    }
    contentItem: Column {}
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
    focus: true

    enter: Transition {
        NumberAnimation {
            property: "opacity"
            from: 0.0
            to: 1.0
        }
    }
    exit: Transition {
        NumberAnimation {
            property: "opacity"
            from: 1.0
            to: 0.0
        }
    }
}
