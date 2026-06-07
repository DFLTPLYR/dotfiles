import QtQuick
import QtQuick.Controls.Basic
import qs.core

Menu {
    id: menu

    padding: 2

    delegate: MenuItem {
        id: menuItem

        implicitWidth: 100
        implicitHeight: 40

        arrow: Canvas {
            x: parent.width - width
            implicitWidth: 40
            implicitHeight: 40
            visible: menuItem.subMenu
            onPaint: {
                var ctx = getContext("2d");
                ctx.fillStyle = menuItem.highlighted ? Qt.darker(Colors.theme.surface, 1.5) : Colors.theme.surface;
                ctx.moveTo(15, 15);
                ctx.lineTo(width - 15, height / 2);
                ctx.lineTo(15, height - 15);
                ctx.closePath();
                ctx.fill();
            }
        }

        indicator: Item {
            id: indicator

            implicitWidth: 40
            implicitHeight: 40

            Rectangle {
                width: 26
                height: 26
                anchors.centerIn: parent
                visible: menuItem.checkable
                border.color: Colors.theme.outline
                radius: 3

                Rectangle {
                    width: 14
                    height: 14
                    anchors.centerIn: parent
                    visible: menuItem.checked
                    color: Colors.theme.primary
                    radius: 2
                }
            }
        }

        contentItem: Text {
            leftPadding: menuItem.checkable ? menuItem.indicator.width : 0
            rightPadding: menuItem.subMenu ? menuItem.arrow.width : 0
            text: menuItem.text
            font: menuItem.font
            opacity: enabled ? 1 : 0.3
            color: menuItem.highlighted ? Colors.theme.on_surface : Colors.theme.primary
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        background: Rectangle {
            implicitWidth: 100
            implicitHeight: 40
            opacity: enabled ? 1 : 0.3
            color: menuItem.highlighted ? Colors.theme.surface : "transparent"
        }
    }

    background: Rectangle {
        clip: true
        implicitWidth: 100
        implicitHeight: 40
        color: Colors.theme.surface
        border.color: Colors.theme.outline
        radius: 2
    }
}
