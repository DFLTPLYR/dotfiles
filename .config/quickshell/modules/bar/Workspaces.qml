import QtQuick
import QtQuick.Controls

import Quickshell
import Quickshell.Hyprland

import qs
import qs.assets
import qs.services
import qs.modules

Item {
    id: root
    implicitWidth: monitorRow.implicitWidth
    implicitHeight: monitorRow.implicitHeight
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
        spacing: 8

        Repeater {
            model: Hyprland.workspaces
            delegate: Item {
                width: 40
                height: 40
                visible: modelData.id >= 0

                Rectangle {
                    id: monitorIndicator
                    anchors.centerIn: parent
                    implicitWidth: parent.width / 1.25
                    implicitHeight: parent.height / 1.25
                    radius: 100

                    // Track hover state
                    property bool hovered: false

                    color: hovered ? Assets.color14 : (modelData.active && modelData.focused) ? Assets.color2 : "transparent"

                    // Animate the fill color
                    Behavior on color {
                        ColorAnimation {
                            duration: 250
                            easing.type: Easing.InOutQuad
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: kanjiNumber(modelData.id - 1)
                        color: monitorIndicator.hovered ? Assets.color2 : (modelData.active && modelData.focused) ? Assets.color14 : Assets.color2
                        font.pixelSize: 12
                        // Animate the fill color
                        Behavior on color {
                            ColorAnimation {
                                duration: 250
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: modelData.activate()
                        onEntered: {
                            monitorIndicator.hovered = true;
                        }
                        onExited: monitorIndicator.hovered = false
                    }
                }
            }
        }
    }
}
