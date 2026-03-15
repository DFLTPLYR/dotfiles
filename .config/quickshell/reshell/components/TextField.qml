import QtQuick
import QtQuick.Controls.Basic
import qs.core

TextField {
    id: control
    placeholderText: qsTr("Enter description")

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: 40
        color: control.enabled ? Qt.darker(Colors.color.background, 1.15) : Colors.color.background
        border.color: control.enabled ? Qt.darker(Colors.color.outline, 1.15) : Colors.color.outline
    }
}
