import QtQuick
import QtQuick.Controls.Basic
import qs.core

TextField {
    id: control

    placeholderText: qsTr("Enter description")

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: 40
        color: control.enabled ? Qt.darker(Colors.theme.surface, 1.15) : Colors.theme.surface
        border.color: control.enabled ? Qt.darker(Colors.theme.outline, 1.15) : Colors.theme.outline
    }
}
