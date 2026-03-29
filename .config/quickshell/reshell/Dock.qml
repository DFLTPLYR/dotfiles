import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.core
import qs.modules

PanelWindow {
    id: panel
    color: "transparent"
    property string pos: {
        const positions = ["top", "bottom", "left", "right"];
        return positions[Math.floor(Math.random() * positions.length)];
    }
    property bool side: panel.pos === "left" || "right"
    property var config: QtObject {
        property real x: 0
        property real y: 0
        property real width: 10
        property real height: 10
    }

    anchors {
        top: panel.pos === "top"
        bottom: panel.pos === "bottom"
        left: panel.pos === "left"
        right: panel.pos === "right"
    }

    implicitHeight: screen.height
    implicitWidth: screen.width

    exclusionMode: ExclusionMode.Auto
    exclusiveZone: panel.side ? container.width : container.height
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: `Top-${screen.name}`

    mask: Region {
        regions: []
    }

    Rectangle {
        id: container
        state: panel.pos
        states: [
            State {
                name: "left"
                PropertyChanges {
                    target: container
                    x: 0
                    y: parent.height * (config.y / 100)
                    width: config.width || 40
                    height: parent.height * (config.height / 100) || parent.height
                }
            },
            State {
                name: "right"
                PropertyChanges {
                    target: container
                    x: parent.width - (config.width || 40)
                    y: parent.height * (config.y / 100)
                    width: config.width || 40
                    height: parent.height * (config.height / 100) || parent.height
                }
            },
            State {
                name: "top"
                PropertyChanges {
                    target: container
                    x: parent.width * (config.x / 100)
                    y: 0
                    width: parent.width * (config.width / 100) || parent.width
                    height: config.height || 40
                }
            },
            State {
                name: "bottom"
                PropertyChanges {
                    target: container
                    x: parent.width * (config.x / 100)
                    y: parent.height - (config.height || 40)
                    width: parent.width * (config.width / 100) || parent.width
                    height: config.height || 40
                }
            }
        ]
        transitions: [
            Transition {
                from: "*"
                to: "*"
                NumberAnimation {
                    properties: "width,height"
                    duration: 100
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    properties: "x,y"
                    duration: 100
                    easing.type: Easing.InOutQuad
                }
            }
        ]
    }
}
