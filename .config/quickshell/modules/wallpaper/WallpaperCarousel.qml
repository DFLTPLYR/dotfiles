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

PanelWindow {
    id: toplevel
    screen: screenRoot.modelData

    color: "transparent"

    implicitWidth: Math.round(screen.width)
    implicitHeight: Math.round(screen.height)

    visible: internalVisible

    focusable: internalVisible

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    property bool shouldBeVisible: false
    property bool internalVisible: false
    property real animProgress: 0.0

    // Manual animator
    NumberAnimation on animProgress {
        id: anim
        duration: 300
        easing.type: Easing.InOutQuad
    }

    onShouldBeVisibleChanged: {
        anim.to = shouldBeVisible ? 1.0 : 0.0;
        anim.restart();
    }

    onAnimProgressChanged: {
        if (animProgress > 0 && !internalVisible) {
            internalVisible = true;
        } else if (!shouldBeVisible && animProgress === 0.00) {
            internalVisible = false;
            const drawerKey = `WallpaperCarousel-${screen.name}`;
            GlobalState.removeDrawer(drawerKey);
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

                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Escape || event.key === Qt.Key_Up || event.key === Qt.Key_Down || event.key === Qt.Key_Left || event.key === Qt.Key_Right) {
                                input.focus = false;
                                flick.forceActiveFocus();
                                event.accepted = true;
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
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            GlobalState.toggleDrawer("wallpaper");
        }
        hoverEnabled: true
    }

    Connections {
        target: GlobalState
        function onShowWallpaperCarouselSignal(value, monitorName) {
            shouldBeVisible = (monitorName === screen.name) ? value : false;
        }
    }

    Component.onCompleted: {
        if (this.WlrLayershell != null) {
            this.WlrLayershell.layer = WlrLayer.Overlay;
        }
    }
}
