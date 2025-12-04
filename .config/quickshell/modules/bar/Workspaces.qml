import QtQuick
import QtQuick.Controls

import Quickshell
import Quickshell.Hyprland

import qs.config
import qs.assets
import qs.utils
import qs.services

Item {
    id: root
    property string location
    property string activeStyle
    property string styles
    property string style
    function kanjiNumber(n) {
        const kanji = ["〇", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十"];
        return kanji[n] !== undefined ? kanji[n] : n.toString();
    }

    function romanNumber(n) {
        const roman = ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"];
        return roman[n] !== undefined ? roman[n] : n.toString();
    }

    Component {
        id: portrait
        Column {
            height: parent.height
            spacing: 2

            Repeater {
                model: Hyprland.workspaces
                delegate: Item {
                    required property var modelData
                    height: parent.width
                    width: parent.width
                    visible: modelData.id >= 0

                    Rectangle {
                        id: monitorIndicator
                        anchors.centerIn: parent
                        height: parent.height
                        width: height
                        radius: height * 0.2
                        color: mouseArea.containsMouse ? Scripts.setOpacity(Color.color14, 0.4) : (modelData.active && modelData.focused) ? Color.color2 : "transparent"

                        // Animate the fill color
                        Behavior on color {
                            ColorAnimation {
                                duration: 250
                                easing.type: Easing.InOutQuad
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: {
                                switch (Config.navbar.extendedBar.style) {
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

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                modelData.activate();
                                var apps = modelData.toplevels;
                                for (var i = 0; i < apps.values.length; i++) {
                                    console.log(JSON.stringify(apps.values[i].class));
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: landscape
        Row {
            id: monitorRow
            height: parent.height
            spacing: 2

            Repeater {
                model: Hyprland.workspaces
                delegate: Item {
                    required property var modelData
                    height: parent.height
                    width: height
                    visible: modelData.id >= 0

                    Rectangle {
                        id: monitorIndicator
                        anchors.centerIn: parent
                        height: parent.height
                        width: height
                        radius: height * 0.2
                        color: mouseArea.containsMouse ? Scripts.setOpacity(Color.color14, 0.4) : (modelData.active && modelData.focused) ? Color.color2 : "transparent"

                        // Animate the fill color
                        Behavior on color {
                            ColorAnimation {
                                duration: 250
                                easing.type: Easing.InOutQuad
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: {
                                switch (Config.navbar.extended.style) {
                                case "kanji":
                                    return kanjiNumber(modelData.id - 1);
                                case "roman":
                                    return romanNumber(modelData.id - 1);
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

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                modelData.activate();
                                var apps = modelData.toplevels;
                                for (var i = 0; i < apps.values.length; i++) {
                                    console.log(JSON.stringify(apps.values[i].class));
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Loader {
        anchors.fill: parent
        sourceComponent: Config.navbar.side ? portrait : landscape
    }
}
