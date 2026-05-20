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

        onIsRegisteredChanged: console.info("Polkit Agent Started")

        onIsActiveChanged: {
            if (isActive && isRegistered) {
                console.info("Polkit Agent Request Received");
            }
        }
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
                anchors.centerIn: parent
                height: 100
                width: 300

                ColumnLayout {
                    anchors.fill: parent
                    // Message Context
                    RowLayout {
                        spacing: 8

                        Layout.fillWidth: true

                        Text {
                            text: agent.flow.messagle ?? ""
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
                        placeholderText: agent.flow.inputPrompt
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

                            // function onFailedChanged() {
                            //     if (agent.flow.failed) {
                            //     }
                            // }

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

                        // cancel
                        Button {
                            Layout.preferredWidth: height
                            Layout.fillHeight: true

                            onClicked: agent.flow.cancelAuthenticationRequest()
                        }
                        // submit
                        Button {
                            Layout.preferredWidth: height
                            Layout.fillHeight: true

                            onClicked: agent.flow.submit(textInput.text)
                        }
                    }
                }
            }
        }
    }
}
