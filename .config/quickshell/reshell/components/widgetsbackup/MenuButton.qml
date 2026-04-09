import QtQuick
import QtQuick.Layouts
import Quickshell

import qs.core
import qs.components

Wrapper {
    id: wrap
    // properties
    objectName: "MenuButton"
    setHeight: 50
    setWidth: 50
    relativeX: 0
    relativeY: 0
    position: -1
    // properties

    Button {
        id: button
        enabled: !wrap.active
        anchors {
            fill: parent
            margins: 5
        }

        Icon {
            text: "power-off"
            anchors.centerIn: parent
            color: Colors.color.primary
            font.pixelSize: Math.min(wrap.width, wrap.height) * 0.8
        }

        onClicked: {
            if (!load.active) {
                load.active = true;
                return load.item.state = "show";
            }
            return load.item.state = "hidden";
        }
    }

    LazyLoader {
        id: load
        component: PopupWindow {
            id: test
            property alias state: content.state
            color: "transparent"

            anchor {
                item: button
                edges: Edges.Bottom | Edges.Right
                rect {
                    x: wrap.side ? button.width : (button.width - width) / 2
                    y: wrap.side ? (button.height - height) / 2 : button.height
                }
            }

            implicitWidth: 100
            implicitHeight: content.height
            visible: load.active

            Rectangle {
                id: content
                width: test.width
                implicitHeight: menulist.contentHeight + (wrapper.anchors.margins + border.width)

                border {
                    width: 2
                    color: Colors.color.outline
                }

                state: "hidden"
                color: Colors.color.background

                states: [
                    State {
                        name: "hidden"
                        PropertyChanges {
                            target: content
                            scale: 0.9
                            y: -500
                        }
                    },
                    State {
                        name: "show"
                        PropertyChanges {
                            target: content
                            scale: 1
                            y: 0
                        }
                    }
                ]

                transitions: [
                    Transition {
                        to: "show"
                        NumberAnimation {
                            properties: "x,y,opacity,scale"
                            duration: 300
                            easing.type: Easing.InOutQuad
                        }
                    },
                    Transition {
                        to: "hidden"
                        SequentialAnimation {
                            NumberAnimation {
                                properties: "x,y,opacity,scale"
                                duration: 300
                                easing.type: Easing.InOutQuad
                            }
                            ScriptAction {
                                script: load.active = false
                            }
                        }
                    }
                ]

                Item {
                    id: wrapper
                    anchors {
                        fill: parent
                        margins: 2
                    }
                    ListView {
                        id: menulist
                        height: contentHeight
                        model: ["suspend", "poweroff", "hibernate", "reboot"]
                        delegate: Button {
                            text: modelData
                            width: wrapper.width
                            onClicked: {
                                Quickshell.execDetached({
                                    command: ["sh", "-c", `systemctl ${modelData}`]
                                });
                            }
                        }
                    }
                }
            }
        }
    }
}
