import QtQuick
import QtQuick.Controls.Basic

import qs.core

SwitchDelegate {
    id: toggle
    property var state: Global.general.toggle

    text: qsTr("SwitchDelegate")
    checked: true

    contentItem: Text {
        rightPadding: toggle.indicator.width + toggle.spacing
        text: toggle.text
        font: toggle.font
        opacity: enabled ? 1.0 : 0.3
        color: toggle.state.content.color
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
    }

    indicator: Rectangle {
        implicitWidth: toggle.state.indicator.width
        implicitHeight: toggle.state.indicator.height

        radius: toggle.state.indicator.radius

        x: toggle.width - width - toggle.rightPadding
        y: parent.height / 2 - height / 2

        color: toggle.checked ? toggle.state.indicator.up : toggle.state.indicator.down
        border.color: innerRect.border.color

        anchors {
            right: parent.right
            rightMargin: toggle.rightPadding
            verticalCenter: parent.verticalCenter
        }

        Behavior on color {
            ColorAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }

        Rectangle {
            id: innerRect

            x: toggle.checked ? parent.width - width : 0

            width: toggle.state.indicator.inner.width
            height: toggle.state.indicator.inner.height

            radius: toggle.state.indicator.radius

            color: toggle.down ? toggle.state.indicator.inner.down : toggle.state.indicator.inner.up
            border.color: toggle.checked ? (toggle.down ? toggle.state.indicator.inner.down : Qt.darker(toggle.state.indicator.inner.down, 1.2)) : toggle.state.indicator.inner.up

            anchors {
                verticalCenter: parent.verticalCenter
            }

            Behavior on border.color {
                ColorAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }

            Behavior on x {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }

    background: Item {}
}
