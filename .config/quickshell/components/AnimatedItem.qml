import QtQuick

Item {
    id: root
    property real animationProgress: 0.0
    property bool shouldBeVisible: false
    property bool internalVisible: false

    signal hide

    state: shouldBeVisible ? "visible" : "hidden"

    states: [
        State {
            name: "visible"
            PropertyChanges {
                target: root
                animationProgress: 1.0
                internalVisible: true
            }
        },
        State {
            name: "hidden"
            PropertyChanges {
                target: root
                animationProgress: 0.0
                internalVisible: false
            }
        }
    ]

    transitions: [
        Transition {
            from: "hidden"
            to: "visible"
            NumberAnimation {
                property: "animationProgress"
                duration: 300
                easing.type: Easing.InOutQuad
            }
        },
        Transition {
            from: "visible"
            to: "hidden"
            NumberAnimation {
                property: "animationProgress"
                duration: 300
                easing.type: Easing.InOutQuad
            }
            onRunningChanged: {
                if (!running && root.state === "hidden") {
                    root.hide();
                }
            }
        }
    ]
}
