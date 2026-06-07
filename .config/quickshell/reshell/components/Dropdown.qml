pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic

import qs.core

ComboBox {
    id: control

    delegate: ItemDelegate {
        id: delegate

        required property var model
        required property int index

        width: control.width
        contentItem: Text {
            text: delegate.model[control.textRole]
            color: Colors.theme.on_surface
            font: control.font
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            anchors.fill: parent
            color: delegate.highlighted ? Colors.theme.surface_variant : Colors.theme.surface

            Behavior on color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }
        }
        highlighted: control.highlightedIndex === index
    }

    indicator: Canvas {
        id: canvas
        x: control.width - width - control.rightPadding
        y: control.topPadding + (control.availableHeight - height) / 2
        width: 12
        height: 8
        contextType: "2d"

        Connections {
            target: control
            function onPressedChanged() {
                canvas.requestPaint();
            }
        }

        onPaint: {
            context.reset();
            context.moveTo(0, 0);
            context.lineTo(width, 0);
            context.lineTo(width / 2, height);
            context.closePath();
            context.fillStyle = control.pressed ? Qt.darker(Colors.theme.surface, 1.5) : Colors.theme.surface;
            context.fill();
        }
    }

    contentItem: Text {
        leftPadding: 10
        rightPadding: control.indicator.width + control.spacing

        text: control.displayText
        font: control.font
        color: control.pressed ? Qt.darker(Colors.color.on_primary, 1.5) : Colors.color.on_primary
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        implicitWidth: 120
        implicitHeight: control.contentItem
        color: Colors.color.primary
        border.width: control.visualFocus ? 2 : 1
        radius: 2
    }

    popup: Popup {
        y: control.height - 1
        width: control.width
        // height: Math.min(contentItem.implicitHeight, control.Window.height - topMargin - bottomMargin)
        padding: 1

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex

            ScrollIndicator.vertical: ScrollIndicator {}
        }

        background: Rectangle {
            color: Colors.color.background
            border.color: Colors.color.outline
            radius: 2
        }
    }
}
