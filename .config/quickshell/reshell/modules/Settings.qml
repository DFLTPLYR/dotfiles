import Quickshell
import QtQuick
import QtQuick.Layouts

import qs.core
import qs.components
import qs.modules.pages

Rectangle {
    id: floatingpanel
    readonly property bool isFocused: screen.name === Compositor.focusedMonitor
    property QtObject config: Global.getConfigManager(`${screen.name}-navbar`).adapter
    property bool side: config ? (config.position === "left" || config.position === "right") : false

    signal hidden

    clip: true

    state: 'hide'
    states: [
        State {
            name: "hide"
            PropertyChanges {
                target: floatingpanel
                opacity: 0
            }
        },
        State {
            name: "show"
            PropertyChanges {
                target: floatingpanel
                opacity: 1
                width: screen.width / 1.5
                height: screen.height / 1.5
            }
        }
    ]

    transitions: [
        Transition {
            from: "*"
            to: "hide"
            SequentialAnimation {
                NumberAnimation {
                    properties: "width,height,opacity"
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
                ScriptAction {
                    script: floatingpanel.hidden()
                }
            }
        },
        Transition {
            from: "*"
            to: "show"
            NumberAnimation {
                properties: "width,height,opacity"
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }
    ]

    x: (screen.width - width) / 2
    y: (screen.height - height) / 2

    color: Colors.setOpacity(Colors.color.background, Global.general.opacity)

    border {
        width: 1
        color: Colors.color.outline
    }

    MouseArea {
        id: ma
        enabled: Global.general.moveablesetting
        anchors.fill: parent
        drag.target: floatingpanel
    }

    function getIcon(name) {
        switch (name) {
        case "general":
            return "gear";
        case "navbar":
            return `bar-${config.position}`;
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
            margins: 2
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 20
            Layout.columnSpan: 2
            clip: true
            color: 'transparent'

            PageIndicator {
                anchors.centerIn: parent
                count: tablist.model.length
                currentIndex: stack.currentIndex
            }

            Label {
                font.pixelSize: 16
                text: tablist.model[tablist.currentIndex][0].toUpperCase() + tablist.model[tablist.currentIndex].substring(1)
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
                model: ["general", "wallpaper", "docks"]
                delegate: TabButton {}
            }
        }

        StackLayout {
            id: stack
            Layout.fillHeight: true
            Layout.fillWidth: true

            // General
            GeneralPage {
                windowconfig: floatingpanel.config
            }

            // Wallpaper
            WallpaperPage {}

            // Docks
            DocksPage {
                property var reshell: Global.getConfigManager(`${screen.name}-navbar`)
                windowconfig: floatingpanel.config
                docks: reshell.docklist
                onRemove: item => {
                    const index = reshell.adapter.docks.findIndex(d => d.name === item);
                    if (index !== -1) {
                        reshell.adapter.docks.splice(index, 1);
                        reshell.save();
                    }
                }
            }
        }
    }

    component TabButton: Item {
        height: 50
        width: 50

        // icons
        Rectangle {
            anchors.fill: parent
            color: itemMa.containsMouse ? Colors.color.background : "transparent"
            radius: itemMa.containsMouse ? 8 : 0

            Icon {
                anchors.centerIn: parent
                text: floatingpanel.getIcon(modelData)
                font.pixelSize: parent.height
                color: itemMa.containsMouse || stack.currentIndex === index ? Colors.color.tertiary : Colors.color.primary

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

    Component.onCompleted: {
        Global.bindRadii(floatingpanel);
    }
}
