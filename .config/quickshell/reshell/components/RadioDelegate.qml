import QtQuick
import QtQuick.Controls.Basic
import qs.core

RadioDelegate {
    id: control

    property QtObject config: QtObject {
        property QtObject content: QtObject {
            property color color: Colors.theme.on_surface
        }

        property QtObject indicator: QtObject {
            property color color: Colors.theme.surface
            property color border: Colors.theme.outline
            property color dot: Colors.theme.primary
        }
    }

    text: qsTr("RadioDelegate")
    checked: true
    font.capitalization: Font.Capitalize

    contentItem: Text {
        rightPadding: control.indicator.width + control.spacing
        text: control.text
        font: control.font
        opacity: enabled ? 1.0 : 0.3
        color: control.config.content.color
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
    }

    indicator: Rectangle {
        implicitWidth: 26
        implicitHeight: 26
        x: control.width - width - control.rightPadding
        y: parent.height / 2 - height / 2
        radius: 13
        color: control.config.indicator.color
        border.color: control.down ? Qt.darker(control.config.indicator.border, 1.15) : control.config.indicator.border

        Rectangle {
            width: 14
            height: 14
            x: 6
            y: 6
            radius: 7
            color: control.down ? Qt.darker(control.config.indicator.dot, 1.15) : control.config.indicator.dot
            visible: control.checked
        }
    }

    background: Rectangle {
        implicitWidth: 100
        implicitHeight: 40
        visible: control.down || control.highlighted
        color: "transparent"
    }
}
