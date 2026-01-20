import QtQuick
import QtQuick.Controls
import qs.config

Switch {
    id: root
    property string label: ""
    property color labelColor: Colors.color.secondary
    property int labelSize: 24

    display: AbstractButton.TextBesideIcon

    indicator: Item {
        id: indicator
        height: parent.height
        width: height

        FontIcon {
            font.pixelSize: parent ? Math.min(parent.width, parent.height) * 0.5 : 0
            anchors.centerIn: parent
            color: Colors.color.secondary
            text: root.checked ? "circle-check" : "xmark-circle"
        }
    }

    contentItem: Label {
        anchors.left: indicator.right
        text: root.label
        color: root.labelColor
        font.pixelSize: root.labelSize
    }
}
