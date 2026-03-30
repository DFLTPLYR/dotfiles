import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.core
import qs.modules

Scope {
    id: dock
    property ShellScreen screen
    required property string name

    FileView {
        id: file
        path: Qt.resolvedUrl(`./core/data/docks/${screen.name}+${dock.name}.json`)
        watchChanges: true
        preload: true
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound) {
                file.setText("{}");
                file.writeAdapter();
                Quickshell.reload();
            }
        }
        adapter: JsonAdapter {
            id: config
            property int height: 40
            property int width: 100
            property int x: 0
            property int y: 0
            property string position: "top"
            readonly property bool side: position === "left" || position === "right"
            Component.onCompleted: panelLoader.active = true
        }
    }

    LazyLoader {
        id: panelLoader
        active: false
        component: PanelWindow {
            id: panel
            property JsonAdapter config: file.adapter
            screen: dock.screen
            color: "transparent"
            // color: Colors.setOpacity(Colors.color.background, 0.2)
            objectName: dock.name

            anchors {
                top: config.position === "top"
                bottom: config.position === "bottom"
                left: config.position === "left"
                right: config.position === "right"
            }

            implicitHeight: screen.height
            implicitWidth: screen.width

            exclusionMode: ExclusionMode.Auto
            exclusiveZone: config.side ? config.width : config.height

            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.namespace: `Dock-${panel.name}`

            mask: Region {
                regions: []
            }

            Rectangle {
                id: container
                onHeightChanged: {
                    console.log(height);
                }
                state: config.position
                states: [
                    State {
                        name: "left"
                        PropertyChanges {
                            target: container
                            x: 0
                            y: (parent.height - height) * (config.y / 100)
                            width: panel.config.width
                            height: parent.height * (panel.config.height / 100)
                        }
                    },
                    State {
                        name: "right"
                        PropertyChanges {
                            target: container
                            x: parent.width - config.width
                            y: (parent.height - height) * (config.y / 100)
                            width: config.width
                            height: parent.height * (config.height / 100)
                        }
                    },
                    State {
                        name: "top"
                        PropertyChanges {
                            target: container
                            width: parent.width * (config.width / 100)
                            height: config.height
                            y: 0
                            x: (parent.width - width) * (config.x / 100)
                        }
                    },
                    State {
                        name: "bottom"
                        PropertyChanges {
                            target: container
                            y: parent.height - config.height
                            x: (parent.width - width) * (config.x / 100)
                            width: parent.width * (config.width / 100)
                            height: config.height
                        }
                    }
                ]

                transitions: [
                    Transition {
                        from: "*"
                        to: "*"
                        NumberAnimation {
                            properties: "width,height"
                            duration: 100
                            easing.type: Easing.OutCubic
                        }
                        NumberAnimation {
                            properties: "x,y"
                            duration: 100
                            easing.type: Easing.InOutQuad
                        }
                    }
                ]
            }
        }
    }
}
