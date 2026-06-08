pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Polkit

import qs.core
import qs.components

Scope {
    id: root

    PolkitAgent {
        id: agent
    }

    LazyLoader {
        active: agent.isActive

        PanelWindow {
            id: panel
            visible: true
            color: "transparent"
            exclusiveZone: 0

            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            WlrLayershell.namespace: "reshell-polkit"

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            Pane {
                id: pane
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
                            to: Colors.color.error_container
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
                            text: agent.flow?.message || ""
                            wrapMode: Text.Wrap
                            verticalAlignment: Text.AlignVCenter
                            color: Colors.color.on_background
                            Layout.fillWidth: true
                            Layout.maximumWidth: 300
                        }
                    }

                    // Text Input
                    TextField {
                        id: textInput
                        enabled: agent.flow.isResponseRequired
                        placeholderText: agent.flow?.inputPrompt || ""
                        focus: true
                        echoMode: TextInput.Password
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        onAccepted: agent.flow.submit(text)

                        Keys.onEscapePressed: {
                            agent.flow.cancelAuthenticationRequest();
                        }

                        Connections {
                            target: agent.flow

                            function onFailedChanged() {
                                if (agent.flow.failed) {
                                    pane.state = "shake";
                                }
                            }

                            function onIsResponseRequiredChanged() {
                                if (agent.flow.isResponseRequired) {
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

                            onClicked: agent.flow.cancelAuthenticationRequest()
                        }
                        // submit
                        Button {
                            text: "Submit"

                            onClicked: agent.flow.submit(textInput.text)
                        }
                    }
                }
            }
        }
    }
}
