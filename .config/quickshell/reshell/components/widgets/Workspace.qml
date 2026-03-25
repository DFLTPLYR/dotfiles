import QtQuick
import QtQuick.Layouts
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
    clip: false

    ListView {
        id: list
        property var windows: [...Compositor.workspaces.filter(ws => ws.output === Screen.name && ws.windows?.length === 0)]
        anchors {
            fill: parent
            margins: 2
        }
        orientation: ListView.Horizontal

        model: ScriptModel {
            values: [...list.windows]
        }

        delegate: Button {
            text: index
            height: 30
            width: height
            onClicked: {
                Quickshell.execDetached({
                    command: ["niri", "msg", "action", "focus-workspace", "--", index + 1]
                });
            }
        }
        remove: Transition {
            NumberAnimation {
                property: "x"
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
                properties: "x,y"
                duration: 250
            }
        }
    }
}
