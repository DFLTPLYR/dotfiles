import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell
import Quickshell.Wayland

import qs.config
import qs.components
import qs.widgets
import qs.utils

Variants {
    model: Quickshell.screens
    delegate: PanelWindow {
        id: root

        required property ShellScreen modelData
        readonly property bool isPortrait: screen.height > screen.width
        screen: modelData

        WlrLayershell.namespace: "navbar"
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        anchors {
            left: ["left", "top", "bottom"].includes(Config.navbar.position)
            right: ["right", "top", "bottom"].includes(Config.navbar.position)
            top: ["right", "top", "left"].includes(Config.navbar.position)
            bottom: ["right", "bottom", "left"].includes(Config.navbar.position)
        }

        implicitWidth: Config.navbar.side ? Config.navbar.width : screen.width
        implicitHeight: Config.navbar.side ? screen.height : Config.navbar.height

        color: "transparent"

        Behavior on anchors {
            AnchorAnimation {
                targets: root
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }

        StyledRect {
            id: containerRect
            color: "transparent"
            anchors.fill: parent

            Behavior on height {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }

            Behavior on width {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }

            GridLayout {
                id: slotGrid
                anchors.fill: parent
                columns: Config.navbar.side ? 1 : Config.navbar.layouts.length
                rows: Config.navbar.side ? Config.navbar.layouts.length : 1

                Instantiator {
                    id: slotRepeater
                    model: Config.navbar.layouts
                    delegate: StyledSlot {
                        id: slot
                        required property var modelData
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        parent: slotGrid
                        position: modelData.direction

                        onSlotDestroyed: function (widgets) {
                            widgetHolder.returnChildrenToHolder(widgets, modelData.name);
                        }

                        Component.onCompleted: {
                            Qt.callLater(() => {
                                widgetHolder.reparent();
                            });
                        }
                    }
                }

                Instantiator {
                    model: Config.navbar.widgets
                    delegate: LazyLoader {
                        required property var modelData
                        active: true
                        source: {
                            if (modelData.name !== "") {
                                return Quickshell.shellPath(`widgets/${modelData.name}.qml`);
                            } else {
                                return "";
                            }
                        }

                        onLoadingChanged: {
                            if (!loading && item) {
                                const layoutValue = modelData.layout.valueOf();
                                item.handler = layoutValue;
                                item.parent = widgetHolder;
                                widgetHolder.reparent();
                            }
                        }
                    }
                }

                Item {
                    id: widgetHolder
                    visible: false

                    function returnChildrenToHolder(widgets, slotName) {
                        for (let i = 0; i < widgets.length; i++) {
                            let child = widgets[i];
                            if (child.handler === slotName) {
                                child.isSlotted = false;
                                child.parent = this;
                            }
                        }
                    }

                    function reparent() {
                        const slotMap = Array.from({
                            length: slotRepeater.count
                        }, (_, i) => slotRepeater.objectAt(i)).filter(slot => slot && slot.modelData).reduce((map, slot) => {
                            map[slot.modelData.name] = slot;
                            return map;
                        }, {});
                        children.forEach(child => {
                            const slot = slotMap[child.handler];
                            if (slot) {
                                child.parent = slot;
                            }
                        });
                    }
                }
            }
        }

        LazyLoader {
            id: extendedBarLoader
            property bool shouldBeVisible: false
            component: PopupWrapper {
                shouldBeVisible: extendedBarLoader.shouldBeVisible

                anchor {
                    item: containerRect
                    rect {
                        x: parentWindow.width / 2 - width / 2
                        y: parentWindow.height
                    }
                    margins {
                        top: 0
                        bottom: 0
                        right: 0
                        left: 0
                    }
                }
                implicitWidth: {
                    const percentage = (screen.width * Config.navbar.popup.width) / 100;
                    return percentage;
                }

                implicitHeight: {
                    const percentage = (screen.height * Config.navbar.popup.height) / 100;
                    return percentage;
                }
                color: "transparent"

                onHide: {
                    extendedBarLoader.shouldBeVisible = false;
                    extendedBarLoader.active = false;
                }

                Rectangle {
                    id: container
                    color: containerRect.color
                    border.color: Colors.color.secondary
                    implicitWidth: parent.width
                    implicitHeight: Math.max(1, parent.height * animProgress)
                    y: height * animProgress - (implicitHeight)

                    bottomLeftRadius: 50
                    bottomRightRadius: 50

                    Behavior on height {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.InOutQuad
                        }
                    }

                    Behavior on y {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.InOutQuad
                        }
                    }

                    TabBar {
                        id: bar
                        width: parent.width

                        Repeater {
                            model: ["Media", "Hardware", "Weather"]
                            delegate: CustomTabButton {
                                label: modelData
                            }
                        }
                    }

                    StackLayout {
                        width: parent.width
                        currentIndex: bar.currentIndex
                        Item {
                            id: mediaTab
                        }
                        Item {
                            id: hardwareTab
                        }
                        Item {
                            id: weatherTab
                        }
                    }
                }
            }
        }

        Connections {
            target: Config
            function onOpenExtendedBarChanged() {
                if (screen.name === Config.focusedMonitor.name) {
                    extendedBarLoader.active = true;
                    extendedBarLoader.shouldBeVisible = !extendedBarLoader.shouldBeVisible;
                } else {
                    if (extendedBarLoader.active) {
                        extendedBarLoader.shouldBeVisible = !extendedBarLoader.shouldBeVisible;
                    }
                }
            }
        }
    }

    component CustomTabButton: TabButton {
        property string label: " "
        text: " "
        indicator: Text {
            text: parent.label
            color: parent.checked ? Colors.color.on_primary : parent.background.border.color

            anchors {
                verticalCenter: parent.verticalCenter
                horizontalCenter: parent.horizontalCenter
            }

            Behavior on color {
                ColorAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }
        }
        background: Rectangle {
            color: parent.checked ? Scripts.setOpacity(Colors.color.primary, 0.4) : "transparent"
            border.color: parent.checked ? Colors.color.primary : Colors.color.secondary

            Behavior on color {
                ColorAnimation {
                    duration: 100
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }
}
