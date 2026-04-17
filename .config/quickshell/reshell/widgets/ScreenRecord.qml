import Quickshell

import QtQuick
import QtQuick.Layouts

import qs.core
import qs.components

Wrapper {
    id: wrap
    width: wrap.setSize()
    height: wrap.setSize()

    Button {
        id: button
        enabled: Global.normal

        text: "camcorder"
        anchors.fill: parent

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
                implicitWidth: wrapper.width
                implicitHeight: wrapper.height

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
                    width: popup.width
                    height: 100
                }
            }
        }
    }
}
