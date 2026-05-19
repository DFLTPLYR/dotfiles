import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.core
import qs.types

Wrapper {
    id: wrap

    width: wrap.setSize()
    height: wrap.setSize()

    Rectangle {
        anchors.fill: parent
        color: button.containsMouse || button.toggled ? Colors.setOpacity(Colors.color.primary, 0.2) : "transparent"
        radius: width / 2

        Text {
            anchors.fill: parent
            text: "power-off"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: button.toggled ? Colors.color.tertiary : Colors.color.primary

            font {
                family: Components.icon.family
                weight: Components.icon.weight
                styleName: Components.icon.styleName
                pixelSize: property.icon
            }

            Behavior on color {
                ColorAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
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
                    wrap.modal(null, false);
                    button.toggled = false;
                } else {
                    modal.open();
                    wrap.modal(modal, false);
                    button.toggled = true;
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

    PopupModal {
        id: modal

        width: content.contentWidth + (modal.leftPadding + modal.rightPadding)
        height: content.contentHeight + (modal.bottomPadding + modal.topPadding)
        y: wrap.slotConfig && wrap.slotConfig.side ? wrap.height / 2 - modal.height / 2 : wrap.height
        x: wrap.slotConfig && wrap.slotConfig.side ? wrap.width : wrap.width / 2 - modal.width / 2

        Column {
            id: content

            width: wrap.property.width
            spacing: 0

            ListView {
                id: menulist

                width: 100
                height: contentHeight // implicitHeight also works
                model: ["suspend", "poweroff", "hibernate", "reboot"]

                delegate: Button {
                    text: modelData
                    width: ListView.view.width
                    onClicked: {
                        Quickshell.execDetached({
                            "command": ["sh", "-c", `systemctl ${modelData}`]
                        });
                    }
                }
            }
        }
    }

    property: Property {
        property int icon: 12
        property int width: 100
    }
}
