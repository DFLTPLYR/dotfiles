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
            text: Global.stateNames[Global.state][0]
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: button.toggled ? Colors.color.tertiary : Colors.color.primary
            font.pixelSize: property.size

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

        Behavior on color {
            ColorAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }
    }

    PopupModal {
        id: modal

        width: content.width + (modal.leftPadding + modal.rightPadding)
        height: content.height + (modal.bottomPadding + modal.topPadding)
        y: wrap.slotConfig && wrap.slotConfig.side ? wrap.height / 2 - modal.height / 2 : wrap.height
        x: wrap.slotConfig && wrap.slotConfig.side ? wrap.width : wrap.width / 2 - modal.width / 2

        ColumnLayout {
            id: content

            spacing: 0
            width: wrap.property.width
            height: menulist.height

            ListView {
                id: menulist

                width: parent.width
                height: contentHeight
                model: Global.stateNames

                delegate: Button {
                    text: modelData
                    width: ListView.view.width
                    onClicked: {
                        const idx = Global.stateNames.findIndex(s => {
                            return s === modelData;
                        });
                        if (idx !== -1)
                            Global.state = idx;
                    }
                }
            }
        }
    }

    property: Property {
        property int size: 12
        property int width: 100
    }
}
