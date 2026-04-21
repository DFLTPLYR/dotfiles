import QtQuick
import Quickshell

import qs.core
import qs.types
import qs.components

Wrapper {
    id: wrap

    property: Property {
        property int icon: 12
    }

    width: wrap.setSize()
    height: wrap.setSize()

    Button {
        id: button
        enabled: Global.normal
        text: "power-off"

        anchors {
            fill: parent
        }

        font {
            family: Components.icon.family
            weight: Components.icon.weight
            styleName: Components.icon.styleName
            pixelSize: property.icon
        }

        onClicked: {
            if (modal.opened) {
                modal.close();
                wrap.modal(null);
            } else {
                modal.open();
                wrap.modal(content);
            }
        }
    }

    PopupModal {
        id: modal
        implicitWidth: 120 + modal.background.border.width * 2
        implicitHeight: content.height + modal.background.border.width * 2
        y: wrap.slotConfig.side ? 0 : wrap.height
        x: wrap.slotConfig.side ? wrap.width : 0

        Rectangle {
            id: content
            implicitWidth: menulist.contentWidth
            implicitHeight: menulist.contentHeight

            color: Colors.color.primary

            Item {
                id: wrapper
                width: modal.width
                height: menulist.contentHeight

                ListView {
                    id: menulist
                    height: contentHeight
                    model: ["suspend", "poweroff", "hibernate", "reboot"]
                    delegate: Button {
                        text: modelData
                        width: wrapper.width
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
}
