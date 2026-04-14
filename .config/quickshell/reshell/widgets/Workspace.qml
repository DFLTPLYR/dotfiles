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

        width: wrap.slotConfig ? (wrap.slotConfig.side ? wrap.width : list.contentWidth) : (wrap.parent ? wrap.parent.width : 0)
        height: wrap.slotConfig ? (wrap.slotConfig.side ? list.contentHeight : wrap.height) : (wrap.parent ? wrap.parent.height : 0)

        orientation: wrap.slotConfig ? (wrap.slotConfig.side ? ListView.Vertical : ListView.Horizontal) : ListView.Horizontal

        interactive: false

        model: [...list.windows]

        delegate: Rectangle {
            color: ma.hoveredChanged ? Colors.color.background : Colors.setOpacity(Colors.color.primary, 0.2)
            width: (wrap.slotConfig?.side) ? (wrap.parent?.width || 0) : height
            height: (wrap.slotConfig?.side) ? width : (wrap.parent?.height || 0)

            Behavior on color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }

            Text {
                anchors.centerIn: parent
                text: index + 1
                color: Colors.color.primary
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
