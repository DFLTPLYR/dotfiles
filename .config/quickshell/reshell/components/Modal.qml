import QtQuick
import Quickshell

import qs.core

MouseArea {
    id: ma
    property bool shown: false
    property real posx: 0
    property real posy: 0

    onClicked: {
        ma.shown = !ma.shown;
        ma.posx = mouseX;
        ma.posy = mouseY;

        if (!load.active) {
            load.active = true;
            return load.item.state = "show";
        }
        return load.item.state = "hidden";
    }

    LazyLoader {
        id: load
        component: PopupWindow {
            id: popup
            property alias state: content.state
            color: "transparent"

            anchor {
                item: ma
                rect {
                    x: ma.posx
                    y: ma.posy
                }
            }

            implicitWidth: content.width
            implicitHeight: content.height
            visible: load.active

            Rectangle {
                id: content
                implicitWidth: 100
                implicitHeight: 100

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
            }
        }
    }
}
