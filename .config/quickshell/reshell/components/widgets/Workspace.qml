import QtQuick
import QtQuick.Layouts
import Quickshell

import qs.core

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
        anchors.fill: parent
        orientation: ListView.Horizontal

        model: ScriptModel {
            values: [...list.windows]
        }
        delegate: Rectangle {
            required property var modelData
            height: 40
            width: height
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    console.log(list.model.values);
                    Quickshell.execDetached({
                        command: ["niri", "msg", "focus-window", "--id", modelData.idx]
                    });
                }
            }
        }
        remove: Transition {
            NumberAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: 250
            }
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
            NumberAnimation {
                property: "x"
                from: 200
                to: 0
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
