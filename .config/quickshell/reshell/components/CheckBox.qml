import QtQuick
import QtQuick.Controls.Basic
import qs.core

CheckBox {
    id: control

    text: qsTr("CheckBox")
    checked: true

    indicator: Rectangle {
        implicitWidth: 26
        implicitHeight: 26
        x: control.leftPadding
        y: parent.height / 2 - height / 2
        radius: 3
        color: Colors.theme.surface
        border.color: control.down ? Qt.darker(Colors.theme.outline, 1.15) : Colors.theme.outline

        Rectangle {
            width: 14
            height: 14
            x: 6
            y: 6
            radius: 2
            color: control.down ? Qt.darker(Colors.theme.primary, 1.15) : Colors.theme.primary
            visible: control.checked
        }
    }

    contentItem: Text {
        text: control.text
        font: control.font
        opacity: enabled ? 1 : 0.3
        color: control.down ? Qt.darker(Colors.theme.primary, 1.15) : Colors.theme.primary
        verticalAlignment: Text.AlignVCenter
        leftPadding: control.indicator.width + control.spacing
    }
}
