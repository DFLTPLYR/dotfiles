import QtQuick
import QtQuick.Controls
import QtQuick.Shapes

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets

import qs
import qs.services
import qs.components

import qs.utils

AnimatedScreenOverlay {
    id: toplevel
    screen: screenRoot.modelData
    color: Scripts.hexToRgba(Colors.background, 0.2)

    onClicked: {
        return;
    }

    onHidden: key => GlobalState.removeDrawer(key)

    Item {
        id: keyCatcher
        anchors.fill: parent
        focus: true

        signal keyPressed(var event)

        Keys.onPressed: event => {
            keyPressed(event);
            if (event.key === Qt.Key_Escape) {
                GlobalState.toggleDrawer("wallpaper");
                event.accepted = true;
            }
        }
    }

    PopupWindow {
        id: popup
        readonly property bool isPortrait: screen.height > screen.width

        visible: animProgress > 0
        color: "transparent"

        anchor.window: toplevel
        anchor.adjustment: PopupAdjustment.Slide
        // Target sizes
        property real targetWidth: isPortrait ? screen.width * 0.9 : screen.width * 0.6
        property real targetHeight: screen.height * 0.5

        // Animate using animProgress
        implicitWidth: Math.round(targetWidth)
        implicitHeight: Math.round(targetHeight)

        anchor.rect.x: (screen.width - width) / 2
        anchor.rect.y: (screen.height - height) / 2

        ClippingRectangle {
            id: morphBox
            anchors.centerIn: parent

            width: Math.max(1, popup.targetWidth * animProgress)
            height: Math.max(1, popup.targetHeight * animProgress)

            scale: animProgress
            opacity: animProgress

            radius: Math.min(height, height) / 30
            clip: true

            transformOrigin: Item.Center
            color: Colors.background

            border.color: Colors.foreground
            border.width: 1

            property string wallpaperSearch: ""

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width / 2
                y: 10
                height: 40
                spacing: 10

                Text {
                    text: "Search:"
                    color: Colors.color15
                    font.pixelSize: 24
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    id: inputBox
                    radius: 6
                    color: Colors.color0
                    border.color: Colors.color14
                    border.width: 1
                    height: parent.height
                    width: parent.width - 100

                    TextInput {
                        id: input
                        anchors.fill: parent
                        anchors.margins: 8
                        font.pixelSize: 16
                        color: Colors.color15
                        cursorVisible: true
                        font.capitalization: Font.AllLowercase
                        clip: true

                        onTextChanged: morphBox.wallpaperSearch = text.toLowerCase()

                        Connections {
                            target: keyCatcher
                            function onKeyPressed(event) {
                                const specialKeys = [Qt.Key_Up, Qt.Key_Down, Qt.Key_Left, Qt.Key_Right, Qt.Key_Escape];

                                if (specialKeys.includes(event.key)) {
                                    event.accepted = true;
                                    return;
                                }
                                // Handle Backspace manually
                                if (event.key === Qt.Key_Backspace) {
                                    if (input.text.length > 0) {
                                        input.text = input.text.slice(0, -1);
                                        morphBox.wallpaperSearch = input.text.toLowerCase();
                                    }
                                    event.accepted = true;
                                    return;
                                }

                                // Handle normal key input
                                const keyChar = event.text;
                                if (keyChar && keyChar.length === 1) {
                                    input.text += keyChar;
                                    morphBox.wallpaperSearch = input.text.toLowerCase();
                                    input.forceActiveFocus();
                                    event.accepted = true;
                                }
                            }
                        }
                    }
                }
            }

            ListContent {
                id: flick
                width: parent.width
                height: parent.height
                visible: animProgress > 0
                opacity: animProgress

                Connections {
                    target: keyCatcher
                    function onKeyPressed(event) {
                        switch (event.key) {
                        case Qt.Key_Slash:
                            input.forceActiveFocus();
                            event.accepted = true;
                            break;
                        case Qt.Key_Enter:
                        case Qt.Key_Return:
                            {
                                const index = flick.currentIndex;
                                const model = flick.model;
                                if (model && model.values && index >= 0 && index < model.values.length) {
                                    const path = model.values[index].path;
                                    const screenName = screen.name;
                                    WallpaperStore.setWallpaper(screenName, path);
                                }
                                event.accepted = true;
                                break;
                            }
                        case Qt.Key_Left:
                            if (flick.currentIndex > 0)
                                flick.currentIndex -= 1;
                            event.accepted = true;
                            break;
                        case Qt.Key_Right:
                            if (flick.currentIndex < flick.count - 1)
                                flick.currentIndex += 1;
                            event.accepted = true;
                            break;
                        case Qt.Key_Escape:
                            GlobalState.toggleDrawer("wallpaper");
                            event.accepted = true;
                            break;
                        }
                    }
                }
            }
        }
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
