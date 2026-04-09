import QtQuick
import Quickshell

import qs.core
import qs.types

Item {
    id: wrap
    property Property config: Property {
        property int height: 100
        property int width: 100
    }

    width: parent ? (wrap.side ? wrap.defaultsize : list.contentWidth) : 0
    height: parent ? (wrap.side ? list.contentHeight : wrap.defaultsize) : 0

    clip: true

    ListView {
        id: list
        property var windows: [...Compositor.workspaces.filter(ws => ws.output === Screen.name)]
        width: list.contentWidth
        height: wrap.height
        orientation: wrap.side ? ListView.Vertical : ListView.Horizontal
        interactive: !wrap.active

        model: ScriptModel {
            values: [...list.windows]
        }

        delegate: Rectangle {
            color: ma.hoveredChanged ? Colors.color.background : Colors.setOpacity(Colors.color.primary, 0.2)
            width: parent ? (wrap.side ? parent.width : height) : 0
            height: parent ? (wrap.side ? width : parent.height) : 0

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
                anchors.fill: parent
                enabled: !wrap.active
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
                duration: 250
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
