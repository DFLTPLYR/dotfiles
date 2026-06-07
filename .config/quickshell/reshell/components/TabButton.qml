import QtQuick
import QtQuick.Controls
import qs.core

TabButton {
    id: tabButton

    background: Rectangle {
        anchors.fill: parent
        color: tabButton.checked ? Colors.theme.surface : Colors.theme.on_surface

        border {
            width: 1
            color: Colors.theme.outline

            Behavior on color {
                ColorAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }
    }

    contentItem: Label {
        leftPadding: 5
        anchors.fill: parent
        text: tabButton.text
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
        color: tabButton.checked ? Colors.theme.on_surface : Colors.theme.surface

        Behavior on color {
            ColorAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }
    }
}
