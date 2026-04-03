import QtQuick

import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import qs.core
import qs.types

Scope {
    id: dock
    property ShellScreen screen
    required property string name
    signal addDock(var item)

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
            property StyleJson style: StyleJson {
                color: Colors.setOpacity(Colors.color.background, 0.5)
            }
            property list<var> slots: []

            function save() {
                file.writeAdapter();
            }
            Component.onCompleted: panelLoader.active = true
        }
        function updateColor() {
            config.style.color = Colors.color.background;
            config.style.border.color = Colors.color.outline;
        }
    }

    LazyLoader {
        id: panelLoader
        active: false
        component: PanelWindow {
            id: panel
            property JsonAdapter config: file.adapter
            property int size: config.side ? config.width : config.height
            signal openwidgets
            signal openslots

            screen: dock.screen
            color: "transparent"
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

            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.namespace: `Dock-${panel.name}`

            mask: Region {
                regions: [
                    Region {
                        item: container
                    },
                    Region {
                        item: widgetloader.item
                    },
                    Region {
                        item: slotloader.item
                    }
                ]
            }

            DockContainer {
                id: container
            }

            // Widgets
            Loader {
                id: widgetloader
                property bool shouldShow: Global.widgetpanelEnabled && Global.widgetpanelTarget === panel
                active: false
                sourceComponent: Rectangle {
                    id: widgetWindow

                    color: Colors.setOpacity(Colors.color.background, 0.5)
                    width: screen.width / 2
                    height: screen.height / 2

                    x: screen.width / 2 - width / 2
                    y: screen.height / 2 - height / 2

                    state: 'hide'
                    states: [
                        State {
                            name: "hide"
                            PropertyChanges {
                                target: widgetWindow
                                opacity: 0
                            }
                        },
                        State {
                            name: "show"
                            PropertyChanges {
                                target: widgetWindow
                                opacity: 1
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
                                    script: {
                                        widgetloader.active = false;
                                        Global.widgetpanelEnabled = false;
                                        Global.widgetpanelTarget = null;
                                    }
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

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            widgetWindow.state = "hide";
                        }
                    }
                }

                onShouldShowChanged: {
                    if (shouldShow) {
                        active = true;
                    } else if (item) {
                        item.state = 'hide';
                    }
                }

                onLoaded: {
                    item.state = 'show';
                }
            }

            // Slots
            Loader {
                id: slotloader
                property bool shouldShow: Global.slotpanelEnabled && Global.slotpanelTarget === panel
                active: false
                sourceComponent: Rectangle {
                    id: slotWindow

                    color: Colors.setOpacity(Colors.color.background, 0.5)
                    width: screen.width / 2
                    height: screen.height / 2
                    x: screen.width / 2 - width / 2
                    y: screen.height / 2 - height / 2

                    border {
                        width: 2
                        color: Colors.color.primary
                    }

                    state: 'hide'
                    states: [
                        State {
                            name: "hide"
                            PropertyChanges {
                                target: slotWindow
                                opacity: 0
                            }
                        },
                        State {
                            name: "show"
                            PropertyChanges {
                                target: slotWindow
                                opacity: 1
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
                                    script: {
                                        slotloader.active = false;
                                        Global.slotpanelEnabled = false;
                                        Global.slotpanelTarget = null;
                                    }
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

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            slotWindow.state = "hide";
                        }
                    }
                }

                onShouldShowChanged: {
                    if (shouldShow) {
                        active = true;
                    } else if (item) {
                        item.state = 'hide';
                    }
                }

                onLoaded: {
                    item.state = 'show';
                }
            }

            Component.onCompleted: {
                dock.addDock({
                    panel: panel,
                    config: config
                });
                Global.bindRadii(container, config.style.rounding);
                Global.bindMargins(container, config.style.margin);
            }
        }
    }

    component DockContainer: Rectangle {
        id: container
        color: config.style.color
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
}
