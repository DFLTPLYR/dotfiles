import QtQuick
import QtQuick.Controls.Basic
import qs.core

CheckBox {
    id: control

    property QtObject state: QtObject {
        property QtObject content: QtObject {
            property color color: Colors.theme.primary
        }

        property QtObject indicator: QtObject {
            property color color: Colors.theme.primary
            property color border: Colors.theme.outline
        }
    }

    text: qsTr("CheckBox")
    checked: true

    indicator: Rectangle {
        implicitWidth: 26
        implicitHeight: 26
        x: control.leftPadding
        y: parent.height / 2 - height / 2
        radius: 3
        color: control.state.indicator.color
        border.color: control.down ? Qt.darker(control.state.indicator.border, 1.15) : control.state.indicator.border

        Rectangle {
            width: parent.width / 2
            height: parent.height / 2
            anchors.centerIn: parent
            radius: 2
            color: control.down ? Qt.darker(Colors.theme.primary, 1.15) : Colors.theme.primary
            visible: control.checked
        }
    }

    contentItem: Text {
        text: control.text
        font: control.font
        opacity: enabled ? 1 : 0.3
        color: control.down ? Qt.darker(control.state.content.color, 1.15) : control.state.content.color
        verticalAlignment: Text.AlignVCenter
        leftPadding: control.indicator.width + control.spacing
    }
}
