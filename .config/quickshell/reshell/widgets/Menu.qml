import QtQuick
import QtQuick.Layouts
import Quickshell

import qs.core
import qs.types
import qs.components

Wrapper {
    id: wrap

    property: Property {
        property int icon: 12
        property int width: 100
    }

    width: wrap.setSize()
    height: wrap.setSize()

    Rectangle {
        anchors.fill: parent
        color: button.containsMouse || button.toggled ? Colors.setOpacity(Colors.color.primary, 0.2) : "transparent"
        radius: width / 2

        Behavior on color {
            ColorAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }

        Text {
            anchors.fill: parent
            text: "power-off"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            color: button.toggled ? Colors.color.tertiary : Colors.color.primary
            Behavior on color {
                ColorAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }
            font {
                family: Components.icon.family
                weight: Components.icon.weight
                styleName: Components.icon.styleName
                pixelSize: property.icon
            }
        }

        MouseArea {
            id: button
            property bool toggled: false
            enabled: Global.normal
            hoverEnabled: true

            anchors.fill: parent

            onClicked: {
                if (modal.opened) {
                    modal.close();
                    wrap.modal(null);
                    button.toggled = false;
                } else {
                    modal.open();
                    wrap.modal(content);
                    button.toggled = true;
                }
            }
        }
    }

    PopupModal {
        id: modal
        width: content.contentWidth + (modal.leftPadding + modal.rightPadding)
        height: content.contentHeight + (modal.bottomPadding + modal.topPadding)
        y: wrap.slotConfig && wrap.slotConfig.side ? wrap.height / 2 - modal.height / 2 : wrap.height
        x: wrap.slotConfig && wrap.slotConfig.side ? wrap.width : wrap.width / 2 - modal.width / 2

        ColumnLayout {
            id: content
            spacing: 0
            width: wrap.property.width
            height: menulist.height

            ListView {
                id: menulist
                width: 100
                height: contentHeight
                model: ["suspend", "poweroff", "hibernate", "reboot"]
                delegate: Button {
                    text: modelData
                    width: ListView.view.width
                    onClicked: {
                        Quickshell.execDetached({
                            command: ["sh", "-c", `systemctl ${modelData}`]
                        });
                    }
                }
            }
        }
    }
}
