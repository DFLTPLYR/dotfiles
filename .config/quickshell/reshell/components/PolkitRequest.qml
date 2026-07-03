import QtQuick
import QtQuick.Layouts
import qs.core

Pane {
    id: pane
    required property var request
    property real originX: x
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    height: 120
    width: 300

    states: [
        State {
            name: "shake"
            PropertyChanges {
                target: pane
            }
        }
    ]

    transitions: Transition {
        from: "*"
        to: "shake"

        SequentialAnimation {
            ColorAnimation {
                target: pane.bg
                property: "border.color"
                to: Colors.theme.error
                duration: 100
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                target: pane
                property: "x"
                to: pane.originX - 10
                duration: 100
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                target: pane
                property: "x"
                to: pane.originX + 10
                duration: 100
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                target: pane
                property: "x"
                to: pane.originX - 10
                duration: 100
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                target: pane
                property: "x"
                to: pane.originX + 10
                duration: 100
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                target: pane
                property: "x"
                to: pane.originX
                duration: 100
                easing.type: Easing.InOutQuad
            }
            ColorAnimation {
                target: pane.bg
                property: "border.color"
                to: Colors.theme.outline
                duration: 100
                easing.type: Easing.InOutQuad
            }
            ScriptAction {
                script: pane.state = ""
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        // Message Context
        RowLayout {
            spacing: 8

            Layout.fillWidth: true

            Text {
                text: pane.request.flow?.message || ""
                wrapMode: Text.Wrap
                verticalAlignment: Text.AlignVCenter
                color: Colors.theme.on_surface
                Layout.fillWidth: true
                Layout.maximumWidth: 300
            }
        }

        // Text Input
        TextField {
            id: textInput
            enabled: pane.request.flow.isResponseRequired
            placeholderText: pane.request.flow?.inputPrompt || ""
            focus: true
            echoMode: TextInput.Password
            Layout.fillWidth: true
            Layout.fillHeight: true

            onAccepted: pane.request.flow.submit(text)

            Keys.onEscapePressed: {
                pane.request.flow.cancelAuthenticationRequest();
            }

            Connections {
                target: pane.request.flow

                function onFailedChanged() {
                    if (pane.request.flow.failed) {
                        pane.state = "shake";
                    }
                }

                function onIsResponseRequiredChanged() {
                    if (pane.request.flow.isResponseRequired) {
                        textInput.clear();
                        textInput.forceActiveFocus();
                    }
                }
            }
        }

        // Buttons
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight

            // cancel
            Button {
                text: "Cancel"

                onClicked: pane.request.flow.cancelAuthenticationRequest()
            }

            // submit
            Button {
                text: "Submit"

                onClicked: pane.request.flow.submit(textInput.text)
            }
        }
    }
}
