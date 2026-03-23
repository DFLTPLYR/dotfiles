import QtQuick
import QtQuick.Controls.Basic
import qs.core

MenuBar {
    id: menuBar

    delegate: MenuBarItem {
        id: menuBarItem

        contentItem: Text {
            text: menuBarItem.text
            font: menuBarItem.font
            opacity: enabled ? 1.0 : 0.3
            color: menuBarItem.highlighted ? Colors.color.primary : Colors.color.primary
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight

            Behavior on color {
                ColorAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }
        }

        background: Rectangle {
            implicitWidth: 40
            implicitHeight: 40
            opacity: enabled ? 1 : 0.3
            color: menuBarItem.highlighted ? Qt.darker(Colors.color.background, 1.5) : "transparent"

            Behavior on color {
                ColorAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }

    background: Rectangle {
        implicitWidth: 40
        implicitHeight: 40

        color: Colors.color.background
    }
}
