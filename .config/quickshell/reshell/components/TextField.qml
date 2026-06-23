import QtQuick
import QtQuick.Controls.Basic
import qs.core

TextField {
    id: control

    placeholderText: qsTr("Enter description")

    background: Rectangle {
        anchors.fill: parent
        border {
            width: 2
            color: Colors.theme.outline
        }
        color: Colors.theme.on_surface
    }
}
