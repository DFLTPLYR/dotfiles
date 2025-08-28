import QtQuick
import QtQuick.Controls
import QtQuick.Shapes
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets

import qs
import qs.utils
import qs.services
import qs.components

AnimatedScreenOverlay {
    id: toplevel

    screen: screenRoot.modelData
    key: 'WallpaperCarousel'

    color: Scripts.hexToRgba(Colors.background, 0.2)

    onHidden: key => GlobalState.removeDrawer(key)

    KeyboardEventHandler {
        Keys.onPressed: event => {
            switch (event.key) {
            case Qt.Key_Escape:
                searchValue = "";
                GlobalState.toggleDrawer("wallpaper");
                event.accepted = true;
                break;
            case Qt.Key_Backspace:
                searchValue = searchValue.slice(0, -1);
                showSearchInput = true;
                searchTimer.restart();
                event.accepted = true;
                break;
            case Qt.Key_Enter:
            case Qt.Key_Return:
                const currentItem = flick.currentItem;
                if (currentItem) {
                    const screenName = screen.name;
                    const path = currentItem.modelData.path;
                    WallpaperStore.setWallpaper(screenName, path);
                }

                event.accepted = true;
                break;
            case Qt.Key_Right:
            case Qt.Key_Down:
                if (flick.currentIndex < flick.count - 1)
                    flick.currentIndex += 1;
                event.accepted = true;
                break;
            case Qt.Key_Up:
            case Qt.Key_Left:
                if (flick.currentIndex > 0)
                    flick.currentIndex -= 1;
                event.accepted = true;
                break;
            default:
                if (event.text.length > 0) {
                    searchValue += event.text;
                    showSearchInput = true;
                    searchTimer.restart();
                    event.accepted = true;
                }
            }
        }
    }

    Timer {
        id: searchTimer
        interval: 1000
        repeat: false
        onTriggered: {
            showSearchInput = false;
        }
    }

    property string searchValue: ""
    property var tagFilter: []
    property var colorFilter: []
    property bool showSearchInput: false

    readonly property bool isPortrait: screen.height > screen.width

    // Target sizes
    property real targetWidth: screen.width * 0.9
    property real targetHeight: screen.height * 0.8

    // Content
    ColumnLayout {
        width: Math.max(1, targetWidth * animProgress)
        height: Math.max(1, targetHeight * animProgress)

        scale: animProgress

        x: Math.round(screen.width / 2 - width / 2)
        y: Math.round(screen.height / 2 - height / 2)

        clip: true

        RowLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true

            // List Panel
            Rectangle {
                Layout.fillHeight: true
                Layout.preferredWidth: parent.width / 4
                color: Scripts.setOpacity(Colors.background, 0.8)
                border.color: Scripts.setOpacity(Colors.colors10, 0.2)
                radius: 10
                clip: true

                ListView {
                    id: flick
                    anchors.fill: parent
                    spacing: 10
                    anchors.margins: 16

                    snapMode: ListView.SnapToItem
                    boundsBehavior: Flickable.StopAtBounds

                    highlightMoveDuration: 250
                    highlightMoveVelocity: 400
                    highlightFollowsCurrentItem: true
                    highlightRangeMode: ListView.StrictlyEnforceRange

                    property bool isPortrait: screen.height > screen.width

                    preferredHighlightBegin: parent.height / 4
                    preferredHighlightEnd: parent.height / 4

                    model: ScriptModel {
                        values: {
                            let wallpapers = isPortrait ? WallpaperStore.portraitWallpapers : WallpaperStore.landscapeWallpapers;
                            return wallpapers;
                        }
                    }

                    delegate: WallpaperItem {}

                    onCurrentItemChanged: {
                        if (currentItem && currentItem.modelData) {
                            previewImage.source = Qt.resolvedUrl(currentItem.modelData.path);
                            previewColorPallete.model = currentItem.modelData.colors.slice(0, 19) || [];
                        } else {
                            previewImage.source = "";
                            previewColorPallete.model = [];
                        }
                    }

                    populate: Transition {
                        NumberAnimation {
                            property: "opacity"
                            from: 0
                            to: 1
                            duration: 1000
                        }
                    }

                    highlight: Rectangle {
                        width: 180
                        height: 40
                        color: Scripts.setOpacity(Colors.color1, 0.4)
                        radius: 10
                    }
                }
            }

            // Preview Panel
            Rectangle {
                id: previewPanel
                Layout.fillHeight: true
                Layout.fillWidth: true
                color: Scripts.setOpacity(Colors.background, 0.8)
                border.color: Scripts.setOpacity(Colors.foreground, 0.2)
                radius: 10

                Item {
                    anchors.fill: parent
                    // image preview
                    Rectangle {
                        id: previewCard
                        anchors.fill: parent
                        color: 'transparent'

                        Image {
                            id: previewImage
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectCrop
                            visible: false
                        }
                        Rectangle {
                            id: previewMask
                            anchors.fill: parent
                            radius: 8
                            clip: true
                            visible: false
                        }

                        OpacityMask {
                            anchors.fill: parent
                            source: previewImage
                            maskSource: previewMask
                        }
                    }

                    // preview description
                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        implicitHeight: 100
                        color: Scripts.setOpacity(Colors.background, 0.6)
                        radius: 8
                        anchors.margins: 10
                        border.color: Scripts.setOpacity(Colors.foreground, 0.2)

                        ColumnLayout {
                            id: previewWrapper
                            anchors.fill: parent
                            visible: flick.currentItem.modelData.colors

                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 50

                                Text {
                                    anchors.centerIn: parent
                                    text: qsTr("\uf1fc Color Pallete \uf1fc ")
                                    color: Colors.color10
                                }
                            }

                            RowLayout {
                                id: previewColorPalleteRow
                                Layout.fillWidth: true
                                Layout.preferredHeight: 50
                                spacing: 8

                                Item {
                                    Layout.fillWidth: true
                                }

                                Repeater {
                                    id: previewColorPallete
                                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                                    model: flick.currentItem.modelData.colors
                                    delegate: Rectangle {
                                        radius: 4
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: width / 2
                                        color: modelData.color
                                        border.color: Scripts.setOpacity(Colors.foreground, 0.1)
                                    }
                                }

                                Item {
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }
                }
            }
        }

        // Rectangle {
        //     Layout.fillWidth: true
        //     Layout.preferredHeight: screen.height / 10
        //     color: Scripts.setOpacity(Colors.background, 0.8)
        //     radius: 10
        //     clip: true
        // }
    }

    Connections {
        target: GlobalState
        function onShowWallpaperCarouselSignal(value, monitorName) {
            const isMatch = monitorName === screen.name;
            if (isMatch) {
                toplevel.shouldBeVisible = value;
            }
        }
    }
}
