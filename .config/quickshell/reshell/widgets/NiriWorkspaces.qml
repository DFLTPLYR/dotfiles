import QtQuick
import Quickshell

import qs.core
import qs.types
import qs.components

Wrapper {
    id: wrap
    clip: true

    property: Property {}

    width: wrap.setWidth(list.contentWidth)
    height: wrap.setHeight(list.contentHeight)

    ListView {
        id: list
        property var windows: [...Compositor.workspaces.filter(ws => ws.output === Screen.name)]
        spacing: 2
        width: wrap.slotConfig ? (wrap.slotConfig.side ? wrap.width : list.contentWidth) : (wrap.parent ? wrap.parent.width : 0)
        height: wrap.slotConfig ? (wrap.slotConfig.side ? list.contentHeight : wrap.height) : (wrap.parent ? wrap.parent.height : 0)

        orientation: wrap.slotConfig ? (wrap.slotConfig.side ? ListView.Vertical : ListView.Horizontal) : ListView.Horizontal

        interactive: false

        model: [...list.windows]

        delegate: Rectangle {
            color: ma.hoveredChanged ? Colors.color.background : Colors.setOpacity(Colors.color.primary, 0.2)
            width: (wrap.slotConfig?.side) ? (wrap.parent?.width || 0) : height
            height: (wrap.slotConfig?.side) ? width : (wrap.parent?.height || 0)
            radius: width / 2

            Behavior on color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }

            Rectangle {
                anchors.centerIn: parent
                width: parent.width / 2
                height: parent.height / 2
                radius: width / 2
                color: index === Compositor.focusedWorkspace.idx - 1 ? Colors.color.primary : Colors.color.tertiary

                Behavior on color {
                    ColorAnimation {
                        duration: 300
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            MouseArea {
                id: ma
                hoverEnabled: true
                propagateComposedEvents: true
                anchors.fill: parent
                enabled: Global.normal
                onClicked: {
                    Quickshell.execDetached({
                        command: ["niri", "msg", "action", "focus-workspace", "--", index + 1]
                    });
                }
            }
        }

        remove: Transition {
            NumberAnimation {
                property: "y"
                to: -200
                duration: 250
            }
        }

        add: Transition {
            NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: 20000
            }
        }

        displaced: Transition {
            NumberAnimation {
                properties: "y"
                duration: 250
            }
        }
    }
}
