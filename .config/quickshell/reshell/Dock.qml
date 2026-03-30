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

            implicitHeight: Global.enableSetting ? screen.height : (config.side ? screen.height : config.height)
            implicitWidth: Global.enableSetting ? screen.width : (!config.side ? screen.width : config.width)

            exclusionMode: ExclusionMode.Ignore
            exclusiveZone: config.side ? config.width : config.height

            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.namespace: `Dock-${panel.name}`

            mask: Region {
                regions: [
                    Region {
                        item: container
                    },
                    Region {
                        item: settingloader.item
                    }
                ]
            }

            Rectangle {
                id: container
                state: config.position
                color: "transparent"
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

                Loader {
                    active: Global.enableSetting
                    sourceComponent: DropArea {
                        id: dropArea
                        width: container.width
                        height: container.height
                        onContainsDragChanged: {
                            container.border.color = containsDrag ? Colors.color.tertiary : "transparent";
                        }
                    }
                }
            }

            Loader {
                id: settingloader
                property bool shouldShow: Global.dockpanel
                active: false
                sourceComponent: Rectangle {
                    x: Global.settingpanel.x
                    y: Global.settingpanel.y
                    width: 500
                    height: 500
                    color: "red"
                    visible: settingloader.shouldShow

                    Rectangle {
                        id: widget
                        width: 50
                        height: 50
                        Drag.active: ma.drag.active

                        MouseArea {
                            id: ma
                            anchors.fill: parent
                            drag.target: widget
                            drag.axis: Drag.XAndYAxis
                        }
                    }
                }
                onShouldShowChanged: {
                    if (shouldShow) {
                        active = true;
                    } else if (item) {
                        item.state = 'hide';
                        Global.settingpanel = null;
                    }
                }
                onLoaded: {
                    // item.state = 'show';
                }
            }

            Component.onCompleted: Global.docks.push(this)
        }
    }
}
