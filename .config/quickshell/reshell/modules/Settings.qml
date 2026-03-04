import QtQuick
import QtQuick.Layouts

import qs.core
import qs.components
import qs.modules.pages

Rectangle {
    id: floatingWindow
    readonly property bool isFocused: screen.name === Compositor.focusedMonitor
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    width: screen.width / 2
    height: screen.height / 2

    color: Colors.setOpacity(Colors.color.background, Global.general.opacity)
    opacity: floatingWindow.isFocused && Global.enableSetting ? 1 : 0

    border {
        width: Global.general.border.width
        color: Global.general.border.color
    }

    bottomLeftRadius: Global.general.rounding.bottomLeft
    bottomRightRadius: Global.general.rounding.bottomRight
    topLeftRadius: Global.general.rounding.topLeft
    topRightRadius: Global.general.rounding.topRight

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

    GridLayout {
        columns: 2
        rows: 2

        anchors {
            fill: parent
            margins: 4
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 10
            Layout.columnSpan: 2

            Text {
                id: label
                text: tablist.model[stack.currentIndex].toUpperCase()
                anchors {
                    centerIn: parent
                }
                color: Colors.color.primary
            }
        }

        // icon container
        Item {
            Layout.fillHeight: true
            Layout.preferredWidth: 50
            clip: true

            ListView {
                id: tablist
                anchors.fill: parent
                spacing: 1
                model: ["general", "navbar", "wallpaper"]
                delegate: Item {
                    height: 50
                    width: 50

                    // icons
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
        }

        StackLayout {
            id: stack
            Layout.fillHeight: true
            Layout.fillWidth: true

            // General
            GeneralPage {}

            // Navbar
            NavbarPage {}

            // Wallpaper
            WallpaperPage {}
        }
    }
}
