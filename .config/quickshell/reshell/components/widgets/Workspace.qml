import QtQuick
import Quickshell

import qs.core
import qs.components

Wrapper {
    id: wrap
    // properties
    objectName: "Workspace"
    setHeight: 100
    setWidth: 100
    relativeX: 0
    relativeY: 0
    position: -1
    // properties

    ListView {
        id: list
        property var windows: [...Compositor.workspaces.filter(ws => ws.output === Screen.name && ws.windows?.length === 0)]
        anchors {
            fill: parent
            margins: 1
        }
        orientation: ListView.Horizontal

        model: ScriptModel {
            values: [...list.windows]
        }

        delegate: Rectangle {
            color: Colors.color.background
            width: height
            height: parent ? parent.height : 0

            Text {
                anchors.centerIn: parent
                text: index + 1
                color: Colors.color.primary
            }

            MouseArea {
                anchors.fill: parent
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
