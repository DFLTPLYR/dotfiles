pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs.core
import qs.components
import qs.modules.settings

Page {
    id: page

    GroupContainer {
        label: "Notification Section"

        Rectangle {
            id: exampleNotif
            color: Colors.theme.on_surface
            radius: 5
            height: pane.height + parent.padding

            anchors {
                left: parent.left
                leftMargin: parent.padding
                right: parent.right
                rightMargin: parent.padding
            }

            Pane {
                id: pane
                x: (parent.width - width) / 2
                y: (parent.height - height) / 2
                height: 120
                width: 300

                ColumnLayout {
                    anchors.fill: parent
                    // Message Context
                    RowLayout {
                        spacing: 8

                        Layout.fillWidth: true

                        Text {
                            text: "Message"
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
                    }

                    // Buttons
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignRight

                        // cancel
                        Button {
                            text: "Cancel"
                        }

                        // submit
                        Button {
                            text: "Submit"
                        }
                    }
                }
            }
        }
    }
}
