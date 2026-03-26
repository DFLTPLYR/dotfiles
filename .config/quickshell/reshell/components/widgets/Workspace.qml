import QtQuick
import Quickshell

import qs.core
import qs.components

Wrapper {
    id: wrap
    // properties
    objectName: "Workspace"
    dynamicsize: true
    relativeX: 0
    relativeY: 0
    position: -1
    // properties
    width: parent ? (wrap.side ? parent.width : list.contentWidth) : 0
    height: parent ? (wrap.side ? list.contentHeight : parent.height) : 0
    clip: true

    ListView {
        id: list
        property var windows: [...Compositor.workspaces.filter(ws => ws.output === Screen.name && ws.windows?.length === 0)]
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
            right: parent.right
            leftMargin: wrap.side ? 1 : 0
            rightMargin: wrap.side ? 1 : 0
            topMargin: wrap.side ? 0 : 1
            bottomMargin: wrap.side ? 0 : 1
        }
        width: contentWidth
        orientation: wrap.side ? ListView.Vertical : ListView.Horizontal
        interactive: !wrap.active

        model: ScriptModel {
            values: [...list.windows]
        }

        delegate: Rectangle {
            color: Colors.color.background
            width: height
            height: parent ? (!wrap.side ? parent.height : parent.width) : 0

            Text {
                anchors.centerIn: parent
                text: index + 1
                color: Colors.color.primary
            }

            MouseArea {
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
