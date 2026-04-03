import QtQuick

import qs.core

Rectangle {
    id: panel

    property bool shouldShow: false

    color: Colors.setOpacity(Colors.color.background, 1)
    width: screen.width / 2
    height: screen.height / 2
    x: screen.width / 2 - width / 2
    y: screen.height / 2 - height / 2

    border {
        width: 2
        color: Colors.color.primary
    }

    state: 'hide'
    states: [
        State {
            name: "hide"
            PropertyChanges {
                target: panel
                opacity: 0
            }
        },
        State {
            name: "show"
            PropertyChanges {
                target: panel
                opacity: 1
            }
        }
    ]

    transitions: [
        Transition {
            from: "*"
            to: "hide"
            SequentialAnimation {
                NumberAnimation {
                    properties: "width,height,opacity"
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
                ScriptAction {
                    script: {
                        panel.shouldShow = false;
                    }
                }
            }
        },
        Transition {
            from: "*"
            to: "show"
            NumberAnimation {
                properties: "width,height,opacity"
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }
    ]

    onShouldShowChanged: {
        state = shouldShow ? 'show' : 'hide';
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            panel.shouldShow = false;
        }
    }
}
