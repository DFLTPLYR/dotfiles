import QtQuick
import Quickshell
import qs.components
import qs.core
import qs.types

Wrapper {
    id: wrap

    property: Property {
        property int icon: 12
        property bool dim: false
    }

    width: wrap.setSize()
    height: wrap.setSize()

    onClicked: mouse => {
        if (mouse.button === Qt.RightButton)
            return;
        if (modal.visible) {
            modal.close();
            wrap.area(null);
        } else {
            modal.open();
            wrap.area(modal.background);
        }
    }

    Rectangle {
        anchors.fill: parent
        color: hoverArea.hovered ? Colors.setOpacity(Colors.theme.primary, 0.2) : "transparent"
        radius: width / 2

        Text {
            anchors.fill: parent
            text: "power-off"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: hoverArea.hovered ? Colors.theme.tertiary : Colors.theme.primary

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

        HoverHandler {
            id: hoverArea
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
        dim: wrap.property.dim
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
}
