import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Pipewire

import qs.utils
import qs.assets
import qs.services
import qs.components

import qs.modules.sidebar.todo
import qs.modules.sidebar.Calculator

Scope {
    id: root

    property bool isVisible: false
    signal toggle

    GlobalShortcut {
        id: cancelKeybind
        name: "showSideBar"
        description: "Cancel current action"
        onPressed: {
            Qt.callLater(() => {
                root.isVisible = true;
                root.toggle();
            });
        }
    }

    LazyLoader {
        active: isVisible
        component: PanelWrapper {
            id: sidebarRoot
            implicitWidth: 0

            anchors {
                top: true
                right: true
                bottom: true
            }

            Connections {
                target: root
                function onToggle() {
                    sidebarRoot.shouldBeVisible = !sidebarRoot.shouldBeVisible;
                }
            }

            PopupWindow {
                id: sidebarPopup
                anchor.window: sidebarRoot
                anchor.rect.x: parentWindow.width
                anchor.rect.y: parentWindow.height / 2 - height / 2
                implicitWidth: popupWrapper.width
                implicitHeight: popupWrapper.height
                visible: root.isVisible
                color: 'transparent'

                RowLayout {
                    id: popupWrapper
                    implicitWidth: sideDock.width + (contentLoader.item ? (contentLoader.item.implicitWidth > 0 ? contentLoader.item.implicitWidth : contentLoader.item.width) : 0) + 20

                    implicitHeight: Math.max(sideDock.height, (contentLoader.item ? (contentLoader.item.implicitHeight > 0 ? contentLoader.item.implicitHeight : contentLoader.item.height) : sideDock.height)) + 20

                    x: (1.0 - animProgress) * implicitWidth
                    layoutDirection: Qt.RightToLeft

                    property var currentWidget

                    Rectangle {
                        id: sideDock
                        width: 50
                        height: Math.max(800, sidebarRoot.isPortrait ? screen.height / 2 : screen.height / 2)
                        color: Scripts.setOpacity(Assets.background, 0.4)
                        radius: 10
                        border.color: Assets.color10
                        clip: true

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 4
                            // Statussy
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 8
                                color: 'transparent'
                                border.color: Assets.color10

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 4

                                    Item {
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true

                                        Column {
                                            width: parent.width // span full width so Text centering works
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            spacing: 0

                                            Text {
                                                color: Assets.color14
                                                font.family: FontAssets.fontMaterialRounded
                                                text: TimeService.hoursPadded
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                                width: parent.width
                                                font.pixelSize: {
                                                    var minSize = 10;
                                                    return Math.max(minSize, Math.min(parent.height, parent.width) * 0.5);
                                                }
                                            }
                                            Text {
                                                color: Assets.color14
                                                font.family: FontAssets.fontMaterialRounded
                                                text: TimeService.minutesPadded
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                                width: parent.width
                                                font.pixelSize: {
                                                    var minSize = 10;
                                                    return Math.max(minSize, Math.min(parent.height, parent.width) * 0.5);
                                                }
                                            }
                                        }
                                    }

                                    Item {
                                        id: dateSection
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        property var dayNames: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                                        property var monthShort: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
                                        Column {
                                            width: parent.width
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            spacing: 0
                                            // Month
                                            Text {
                                                color: Assets.color14
                                                font.family: FontAssets.fontMaterialRounded
                                                text: dateSection.monthShort[TimeService.month - 1]
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                                width: parent.width
                                                font.bold: true
                                                font.pixelSize: {
                                                    var minSize = 10;
                                                    return Math.max(minSize, Math.min(height, width) * 0.6);
                                                }
                                            }
                                            // Date of the month
                                            Text {
                                                color: Assets.color14
                                                font.family: FontAssets.fontMaterialRounded
                                                text: Qt.formatDateTime(TimeService.clock.date, "dd")
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                                width: parent.width
                                                font.bold: true
                                                font.pixelSize: {
                                                    var minSize = 10;
                                                    return Math.max(minSize, Math.min(height, width) * 0.6);
                                                }
                                            }
                                            // day of the week
                                            Text {
                                                color: Assets.color14
                                                font.family: FontAssets.fontMaterialRounded
                                                text: dateSection.dayNames[TimeService.day]
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                                width: parent.width
                                                font.bold: true
                                                font.pixelSize: {
                                                    var minSize = 10;
                                                    return Math.max(minSize, Math.min(height, width) * 0.6);
                                                }
                                            }
                                            // Year
                                            Text {
                                                color: Assets.color14
                                                font.family: FontAssets.fontMaterialRounded
                                                text: Qt.formatDateTime(TimeService.clock.date, "yyyy")
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                                width: parent.width
                                                font.bold: true
                                                font.pixelSize: {
                                                    var minSize = 10;
                                                    return Math.max(minSize, Math.min(height, width) * 0.6);
                                                }
                                            }
                                        }
                                    }

                                    Item {
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true

                                        Column {
                                            width: parent.width
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            spacing: 0

                                            Text {
                                                text: "nest_farsight_weather"
                                                color: Assets.color14
                                                font.family: FontAssets.fontMaterialRounded
                                                Layout.fillWidth: true
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                                font.pixelSize: {
                                                    const minSize = 10;
                                                    return Math.max(minSize, Math.min(parent.height, parent.width));
                                                }
                                            }

                                            Text {
                                                color: Assets.color14
                                                font.family: FontAssets.fontMaterialRounded
                                                text: WeatherFetcher.currentCondition?.temp
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                                width: parent.width
                                                font.bold: true
                                                font.pixelSize: {
                                                    var minSize = 10;
                                                    return Math.max(minSize, Math.min(height, width) * 0.6);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            // QuickToolussy
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 8
                                color: 'transparent'
                                border.color: Assets.color10
                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 4

                                    Repeater {
                                        model: [
                                            {
                                                name: "Calculator",
                                                icon: "calculate"
                                            },
                                            {
                                                name: "Apps",
                                                icon: "dashboard"
                                            },
                                            {
                                                name: "Todo",
                                                icon: "list_alt"
                                            },
                                        ]
                                        delegate: Item {
                                            required property var modelData
                                            property bool isHovered: false
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true

                                            Text {
                                                anchors.centerIn: parent
                                                text: modelData.icon
                                                color: hoverArea.containsMouse ? Assets.color10 : Assets.color14
                                                font.family: FontAssets.fontMaterialRounded
                                                Layout.fillWidth: true
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                                font.pixelSize: {
                                                    const minSize = 10;
                                                    return Math.max(minSize, Math.min(parent.height, parent.width));
                                                }

                                                Behavior on color {
                                                    ColorAnimation {
                                                        duration: 300
                                                        easing.type: Easing.InOutQuad
                                                    }
                                                }
                                            }

                                            MouseArea {
                                                id: hoverArea
                                                anchors.fill: parent
                                                hoverEnabled: true

                                                onEntered: {
                                                    isHovered = true;
                                                    cursorShape = Qt.PointingHandCursor;
                                                }
                                                onExited: {
                                                    isHovered = false;
                                                    cursorShape = Qt.ArrowCursor;
                                                }
                                                onClicked: {
                                                    if (popupWrapper.currentWidget === modelData.name) {
                                                        contentLoader.active = false;
                                                        return popupWrapper.currentWidget = null;
                                                    }
                                                    popupWrapper.currentWidget = modelData.name;
                                                    contentLoader.active = true;
                                                    console.log('width: ', popupWrapper.implicitWidth);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            // Miscellaneoussy
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 8
                                color: 'transparent'
                                border.color: Assets.color10
                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 4

                                    Text {
                                        text: "\ue1ff"
                                        color: Assets.color14
                                        font.family: FontAssets.fontMaterialRounded
                                        Layout.fillWidth: true
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        font.pixelSize: {
                                            const minSize = 10;
                                            return Math.max(minSize, Math.min(parent.height, parent.width));
                                        }
                                    }
                                    Text {
                                        text: "\ue1ff"
                                        color: Assets.color14
                                        font.family: FontAssets.fontMaterialRounded
                                        Layout.fillWidth: true
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        font.pixelSize: {
                                            const minSize = 10;
                                            return Math.max(minSize, Math.min(parent.height, parent.width));
                                        }
                                    }
                                    Text {
                                        text: "\ue1ff"
                                        color: Assets.color14
                                        font.family: FontAssets.fontMaterialRounded
                                        Layout.fillWidth: true
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        font.pixelSize: {
                                            const minSize = 10;
                                            return Math.max(minSize, Math.min(parent.height, parent.width));
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Loader {
                        id: contentLoader
                        sourceComponent: {
                            switch (popupWrapper.currentWidget) {
                            case "Calculator":
                                return calculator;
                            case "Apps":
                                return null;
                            case "Todo":
                                return todo;
                            default:
                                return null;
                            }
                        }
                    }

                    Component {
                        id: todo
                        Rectangle {
                            width: 500
                            height: 600
                            color: Scripts.setOpacity(Assets.background, 0.4)
                            radius: 10
                            border.color: Assets.color10
                            clip: true

                            Todo {
                                anchors {
                                    bottom: parent.bottom
                                    top: parent.top
                                    right: parent.right
                                    left: parent.left
                                }
                                width: parent.width
                                height: parent.height
                            }
                        }
                    }
                    Component {
                        id: calculator
                        Rectangle {
                            width: 400
                            height: 500
                            color: Scripts.setOpacity(Assets.background, 0.4)
                            radius: 10
                            border.color: Assets.color10
                            clip: true

                            Calculator {
                                width: parent.width
                                height: parent.height
                                anchors.margins: 4
                            }
                        }
                    }
                }
            }
        }
    }
}
