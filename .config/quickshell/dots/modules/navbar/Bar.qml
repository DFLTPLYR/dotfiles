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
            left: ["left", "top", "bottom"].includes(Navbar.config.position)
            right: ["right", "top", "bottom"].includes(Navbar.config.position)
            top: ["right", "top", "left"].includes(Navbar.config.position)
            bottom: ["right", "bottom", "left"].includes(Navbar.config.position)
        }

        implicitWidth: Navbar.config.side ? Navbar.config.width : screen.width
        implicitHeight: Navbar.config.side ? screen.height : Navbar.config.height

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
                columns: Navbar.config.side ? 1 : Navbar.config.layouts.length
                rows: Navbar.config.side ? Navbar.config.layouts.length : 1

                Instantiator {
                    id: slotRepeater
                    model: Navbar.config.layouts
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
                    model: ScriptModel {
                        values: {
                            const widgets = Navbar.config.widgets.filter(w => {
                                const layout = Navbar.config.layouts.find(s => s.name === w.layout);
                                return w.layout !== "" && layout !== undefined;
                            });
                            return widgets.sort((a, b) => a.position - b.position);
                        }
                    }
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
                                item.widgetWidth = modelData.width;
                                item.widgetHeight = modelData.height;
                                item.height = modelData.height;
                                widgetHolder.reparent();
                            }
                        }
                    }
                }

                Item {
                    id: widgetHolder
                    visible: false
                    onChildrenChanged: {
                        if (children.length > 0) {
                            reparent();
                        }
                    }
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
                    const percentage = (screen.width * Navbar.config.popup.width) / 100;
                    return percentage;
                }

                implicitHeight: {
                    const percentage = (screen.height * Navbar.config.popup.height) / 100;
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
