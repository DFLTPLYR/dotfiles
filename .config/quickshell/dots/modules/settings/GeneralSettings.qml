                        FileDialog {
                            id: fileDialog
                            property Item targetItem
                            currentFolder: StandardPaths.standardLocations(StandardPaths.PicturesLocation)[0]
                            onAccepted: {
                                if (targetItem) {
                                    targetItem.source = selectedFile;
                                    testPanel.source = selectedFile;
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true

                            RowLayout {
                                Layout.fillWidth: true
                                Label {
                                    text: qsTr("Panels:")
                                }

                                Repeater {
                                    model: Quickshell.screens
                                    delegate: Button {
                                        required property ShellScreen modelData
                                        Layout.preferredHeight: 40
                                        Layout.preferredWidth: 80
                                        Text {
                                            anchors {
                                                verticalCenter: parent.verticalCenter
                                                horizontalCenter: parent.horizontalCenter
                                            }
                                            text: modelData.name
                                            color: "white"
                                        }
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 400

                                Item {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                }
                            }

                            // reuse later for preset for panel with BorderImage
                            // Column {
                            //     Layout.fillWidth: true
                            //
                            //     BorderImage {
                            //         id: testPanel
                            //         width: parent.width
                            //         height: 300
                            //
                            //         Rectangle {
                            //             anchors {
                            //                 fill: parent
                            //                 leftMargin: testPanel.border.left
                            //                 rightMargin: testPanel.border.right
                            //                 bottomMargin: testPanel.border.bottom
                            //                 topMargin: testPanel.border.top
                            //             }
                            //             color: Qt.rgba(1, 1, 1, 0.1)
                            //         }
                            //     }
                            // }

                            Switch {
                                text: qsTr("Show Preset Creator Grid")
                                onClicked: presetGrid.visible = !presetGrid.visible
                            }
                        }

                        GridLayout {
                            id: presetGrid
                            visible: false
                            Layout.fillWidth: true
                            Layout.preferredHeight: 200
                            columns: 3

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Column {
                                    anchors {
                                        bottom: parent.bottom
                                        horizontalCenter: parent.horizontalCenter
                                    }
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SpinBox {
                                        from: 0
                                        onValueChanged: {
                                            acceptButtonBg.border.top = value;
                                            testPanel.border.top = value;
                                        }
                                    }
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                Column {
                                    anchors {
                                        right: parent.right
                                        verticalCenter: parent.verticalCenter
                                    }
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    SpinBox {
                                        from: 0
                                        onValueChanged: {
                                            acceptButtonBg.border.left = value;
                                            testPanel.border.left = value;
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                color: "transparent"
                                border.color: "gray"
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Button {
                                    id: testAcceptButton
                                    text: "change panel"
                                    anchors {
                                        horizontalCenter: parent.horizontalCenter
                                        verticalCenter: parent.verticalCenter
                                    }
                                    width: 150
                                    height: 50
                                    background: BorderImage {
                                        id: acceptButtonBg
                                        anchors {
                                            fill: parent
                                            margins: 1
                                        }
                                        border {
                                            left: 1
                                            top: 1
                                            right: 1
                                            bottom: 1
                                        }
                                        horizontalTileMode: BorderImage.Stretch
                                        verticalTileMode: BorderImage.Stretch
                                    }
                                    onClicked: {
                                        fileDialog.targetItem = acceptButtonBg;
                                        fileDialog.open();
                                    }
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Column {
                                    anchors {
                                        left: parent.left
                                        verticalCenter: parent.verticalCenter
                                    }

                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SpinBox {
                                        from: 0
                                        onValueChanged: {
                                            acceptButtonBg.border.right = value;
                                            testPanel.border.right = value;
                                        }
                                    }
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                                Column {
                                    anchors {
                                        top: parent.top
                                        horizontalCenter: parent.horizontalCenter
                                    }
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SpinBox {
                                        from: 0
                                        onValueChanged: {
                                            acceptButtonBg.border.bottom = value;
                                            testPanel.border.bottom = value;
                                        }
                                    }
                                }
                            }
                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                Column {
                                    Rectangle {
                                        width: 150
                                        height: 20
                                        color: Qt.rgba(1, 1, 1, 0.1)
                                        clip: true
                                        TextInput {
                                            id: inputField
                                            anchors.fill: parent
                                            color: "white"
                                            font.pixelSize: parent.height
                                        }
                                    }
                                    Button {
                                        text: "save"
                                        enabled: inputField.text.length > 0
                                        onClicked: {
                                            const preset = {};
                                            preset.name = inputField.text;
                                            preset.border = {
                                                left: acceptButtonBg.border.left,
                                                top: acceptButtonBg.border.top,
                                                right: acceptButtonBg.border.right,
                                                bottom: acceptButtonBg.border.bottom
                                            };
                                            preset.source = acceptButtonBg.source;
                                            Config.general.presets.push(preset);
                                            Config.saveSettings();
                                        }
                                    }
                                }
                            }
                        }

