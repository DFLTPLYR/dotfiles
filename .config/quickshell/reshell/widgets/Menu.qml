import QtQuick
import Quickshell

import qs.core
import qs.types
import qs.components

Wrapper {
    id: wrap
    property bool show: Global.normal

    onShowChanged: {
        if (load.active && !show) {
            load.item.state = "hidden";
        }
    }

    property: Property {}

    width: wrap.setSize()
    height: wrap.setSize()

    Button {
        id: button
        enabled: Global.normal
        text: "power-off"

        anchors {
            fill: parent
        }

        content.color: load.active ? Colors.color.tertiary : Colors.color.primary

        font {
            family: Components.icon.family
            weight: Components.icon.weight
            styleName: Components.icon.styleName
            pixelSize: parent ? Math.min(parent.width, parent.height) / 3 : 0
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
            id: popup
            property alias state: content.state
            color: "transparent"

            anchor {
                item: button
                rect {
                    x: wrap.slotConfig.side ? button.width : (button.width - width) / 2
                    y: wrap.slotConfig.side ? (button.height - height) / 2 : button.height
                }
            }

            implicitWidth: 120
            implicitHeight: content.height
            visible: load.active

            Rectangle {
                id: content
                implicitWidth: menulist.contentWidth
                implicitHeight: menulist.contentHeight

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
                    width: popup.width
                    height: menulist.contentHeight

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
