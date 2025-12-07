import QtQuick
import Quickshell
import Quickshell.Hyprland

import qs.config
import qs.utils

Item {
    height: Config.navbar.side ? Config.navbar.height : parent.height
    width: Config.navbar.side ? parent.width : Config.navbar.width

    function kanjiNumber(n) {
        const kanji = ["〇", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十"];
        return kanji[n] !== undefined ? kanji[n] : n.toString();
    }

    function romanNumber(n) {
        const roman = ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"];
        return roman[n] !== undefined ? roman[n] : n.toString();
    }

    Loader {
        id: compLoader
        anchors.fill: parent
        sourceComponent: Config.navbar.side ? portrait : landscape
    }

    Component {
        id: landscape
        Row {
            id: content
            spacing: 0
            Repeater {
                model: Hyprland.workspaces
                delegate: Item {
                    required property var modelData
                    visible: modelData.id >= 0

                    implicitHeight: parent.height
                    implicitWidth: parent.height

                    Rectangle {
                        id: monitorIndicator
                        anchors.centerIn: parent
                        height: Config.navbar.height * 0.6
                        width: height
                        color: mouseArea.containsMouse ? Scripts.setOpacity(Color.color14, 0.4) : (modelData.active && modelData.focused) ? Color.color2 : "transparent"

                        Behavior on color {
                            ColorAnimation {
                                duration: 250
                                easing.type: Easing.InOutQuad
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: {
                                if (modelData.id === 0) {
                                    console.log("Using bullet for workspace 0");
                                    return "•";
                                }
                                switch (Config.navbar.extended.style) {
                                case "kanji":
                                    return kanjiNumber(modelData.id - 1);
                                case "roman":
                                default:
                                    return romanNumber(modelData.id - 1);
                                }
                            }
                            color: mouseArea.containsMouse ? Color.color14 : (modelData.active && modelData.focused) ? Color.color14 : Color.color2
                            font.pixelSize: {
                                var minSize = 10;
                                return Math.max(minSize, Math.min(height, width) * 0.6);
                            }
                            // Animate the fill color
                            Behavior on color {
                                ColorAnimation {
                                    duration: 250
                                    easing.type: Easing.InOutQuad
                                }
                            }
                        }
                    }
                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            modelData.activate();
                            var apps = modelData.toplevels;
                        }
                    }
                }
            }
        }
    }

    Component {
        id: portrait
        Column {
            id: content
            Repeater {
                model: Hyprland.workspaces
                delegate: Item {
                    required property var modelData
                    visible: modelData.id >= 0

                    implicitHeight: parent.width
                    implicitWidth: parent.width

                    Rectangle {
                        id: monitorIndicator
                        anchors.centerIn: parent
                        height: Config.navbar.width * 0.6
                        width: height
                        color: mouseArea.containsMouse ? Scripts.setOpacity(Color.color14, 0.4) : (modelData.active && modelData.focused) ? Color.color2 : "transparent"

                        Behavior on color {
                            ColorAnimation {
                                duration: 250
                                easing.type: Easing.InOutQuad
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: {
                                if (modelData.id === 0) {
                                    console.log("Using bullet for workspace 0");
                                    return "•";
                                }
                                switch (Config.navbar.extended.style) {
                                case "kanji":
                                    return kanjiNumber(modelData.id - 1);
                                case "roman":
                                default:
                                    return romanNumber(modelData.id - 1);
                                }
                            }
                            color: mouseArea.containsMouse ? Color.color14 : (modelData.active && modelData.focused) ? Color.color14 : Color.color2
                            font.pixelSize: {
                                var minSize = 10;
                                return Math.max(minSize, Math.min(height, width) * 0.6);
                            }
                            // Animate the fill color
                            Behavior on color {
                                ColorAnimation {
                                    duration: 250
                                    easing.type: Easing.InOutQuad
                                }
                            }
                        }
                    }
                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            modelData.activate();
                            var apps = modelData.toplevels;
                        }
                    }
                }
            }
        }
    }
}
