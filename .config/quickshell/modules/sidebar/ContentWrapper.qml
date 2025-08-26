import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.services
import qs.utils

ColumnLayout {
    id: root
    property int index: 0
    clip: true

    states: [
        State {
            name: "visible"
            when: container.currentIndex === index
            PropertyChanges {
                target: root
                opacity: 1
                visible: true
            }
        },
        State {
            name: "hidden"
            when: container.currentIndex !== index
            PropertyChanges {
                target: root
                opacity: 0
                visible: false
            }
        }
    ]

    transitions: [
        Transition {
            from: "hidden"
            to: "visible"
            NumberAnimation {
                properties: "opacity"
                duration: 200
            }
        },
        Transition {
            from: "visible"
            to: "hidden"
            NumberAnimation {
                properties: "opacity"
                duration: 200
            }
        }
    ]
}
