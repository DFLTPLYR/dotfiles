import QtQuick
import QtQuick.Controls

import Quickshell
import Quickshell.Hyprland

import qs
import qs.assets
import qs.utils
import qs.services
import qs.modules

Item {
    id: root
    implicitWidth: parent.width
    implicitHeight: 32
    anchors.verticalCenter: parent.verticalCenter

    function kanjiNumber(n) {
        const kanji = ["〇", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十"];
        return kanji[n] !== undefined ? kanji[n] : n.toString();
    }

    function romanNumber(n) {
        const roman = ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"];
        return roman[n] !== undefined ? roman[n] : n.toString();
    }

    Row {
        id: monitorRow
        Repeater {
            model: Hyprland.workspaces
            delegate: Item {
                implicitWidth: 32
                height: 32
                visible: modelData.id >= 0

                Rectangle {
                    id: monitorIndicator
                    anchors.centerIn: parent
                    height: parent.height * 0.7
                    width: height
                    radius: parent.height * 0.1

                    color: mouseArea.containsMouse ? Scripts.setOpacity(ColorPalette.color14, 0.4) : (modelData.active && modelData.focused) ? ColorPalette.color2 : "transparent"

                    // Animate the fill color
                    Behavior on color {
                        ColorAnimation {
                            duration: 250
                            easing.type: Easing.InOutQuad
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: romanNumber(modelData.id - 1)
                        color: mouseArea.containsMouse ? ColorPalette.color14 : (modelData.active && modelData.focused) ? ColorPalette.color14 : ColorPalette.color2
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

        // Repeater {
        //     model: Hyprland.toplevels
        //     delegate: Item {
        //         implicitWidth: 32
        //         height: 32

        //         Image {
        //             anchors.centerIn: parent
        //             height: parent.height * 0.7
        //             width: height
        //             source: Quickshell.iconPath(appIconName(modelData.lastIpcObject.class), true) || "qrc:/icons/default-app.svg"

        //             fillMode: Image.PreserveAspectCrop
        //             cache: true
        //             smooth: true
        //             sourceSize.width: width
        //             sourceSize.height: height
        //         }

        //         function appIconName(appClass) {
        //             if (/^steam_app_\d+$/.test(appClass)) {
        //                 return "steam";
        //             }
        //             if (/^brave(-browser)?$/i.test(appClass)) {
        //                 return "brave-browser";
        //             }
        //             switch (appClass) {
        //             case "Spotify":
        //                 return "spotify";
        //             case "Code":
        //                 return "visual-studio-code";
        //             case "steam_app_2073850":
        //                 return "steam";
        //             // Add more mappings as needed
        //             default:
        //                 return appClass;
        //             }
        //         }

        //         Component.onCompleted: console.log(modelData.lastIpcObject.class)
        //     }
        // }
    }
}
