import QtQuick
import QtQuick.Layouts
import QtCore
import QtQuick.Dialogs

import qs.core
import qs.components

Rectangle {
    id: floatingWindow
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    width: screen.width / 2
    height: screen.height / 2

    color: Colors.color.background
    opacity: Global.enableSetting ? 1 : 0

    border {
        width: 1
        color: "white"
    }

    Drag.active: ma.drag.active

    Behavior on opacity {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        drag.target: floatingWindow
        onReleased: {
            floatingWindow.Drag.drop();
        }
    }

    GridLayout {
        columns: 2

        anchors {
            fill: parent
            margins: 4
        }

        Item {
            Layout.fillHeight: true
            Layout.preferredWidth: 50

            ListView {
                anchors.fill: parent
                spacing: 1
                model: ["general", "navbar", "wallpaper"]
                delegate: Item {
                    height: 50
                    width: 50

                    Rectangle {
                        anchors.fill: parent
                        color: itemMa.containsMouse ? Colors.color.background : "transparent"
                        radius: itemMa.containsMouse ? 8 : 0

                        Icon {
                            anchors.centerIn: parent
                            text: floatingWindow.getIcon(modelData)
                            font.pixelSize: parent.height
                            color: itemMa.containsMouse || stack.currentIndex === index ? "white" : Qt.rgba(1, 1, 1, 0.6)

                            Behavior on color {
                                ColorAnimation {
                                    duration: 350
                                    easing.type: Easing.InOutQuad
                                }
                            }
                        }

                        Behavior on radius {
                            NumberAnimation {
                                duration: 350
                                easing.type: Easing.InOutQuad
                            }
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 350
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }

                    MouseArea {
                        id: itemMa
                        hoverEnabled: true
                        anchors.fill: parent
                        onClicked: {
                            stack.currentIndex = index;
                        }
                    }
                }
            }

            // Rectangle {
            //     id: floatingWindow2
            //
            //     width: 20
            //     height: 20
            //     color: Qt.rgba(0, 0, 0, 0.2)
            //
            //     border {
            //         width: 1
            //         color: "white"
            //     }
            //
            //     states: State {
            //         when: ma2.drag.active
            //         ParentChange {
            //             parent: null
            //         }
            //     }
            //     Drag.active: ma2.drag.active
            //
            //     MouseArea {
            //         id: ma2
            //         anchors.fill: parent
            //         drag.target: floatingWindow2
            //         onReleased: {
            //             const target = floatingWindow2.Drag.target;
            //             floatingWindow2.Drag.drop();
            //             if (target) {
            //                 console.log("has");
            //             } else {
            //                 floatingWindow2.x = floatingWindow.x;
            //                 floatingWindow2.y = floatingWindow.y;
            //             }
            //         }
            //     }
            // }
        }

        StackLayout {
            id: stack
            Layout.fillHeight: true
            Layout.fillWidth: true
            Rectangle {
                color: Colors.color.primary
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
            Rectangle {
                color: Colors.color.secondary
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                MouseArea {
                    anchors.fill: parent
                    onClicked: fileDialog.open()
                }
                FileDialog {
                    id: fileDialog
                    fileMode: FileDialog.OpenFile
                    currentFolder: StandardPaths.writableLocation(StandardPaths.PicturesLocation)
                    nameFilters: ["Images (*.png *.jpg *.jpeg *.webp)"]

                    onAccepted: {
                        Wallpaper.config.source.push({
                            monitor: screen.name,
                            timestamp: Date.now(),
                            path: selectedFile
                        });
                        Wallpaper.save();
                    }
                }
            }
        }
    }

    function getIcon(name) {
        switch (name) {
        case "general":
            return "gear";
        case "navbar":
            return `bar-${Navbar.config.position}`;
        case "wallpaper":
            return "hexagon-image";
        default:
            return "?";
        }
    }
}
