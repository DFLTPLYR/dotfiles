import QtQuick
import QtQuick.Controls
import QtQuick.Shapes
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

    onClicked: {
        return;
    }

    onHidden: key => GlobalState.removeDrawer(key)

    Item {
        id: keyCatcher
        anchors.fill: parent
        focus: true

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
                if (flick.currentItem && flick.currentItem.openApp) {
                    flick.currentItem.openApp();
                }
                event.accepted = true;
                break;
            case Qt.Key_Left:
            case Qt.Key_Down:
                if (flick.currentIndex > 0)
                    flick.currentIndex -= 1;
                event.accepted = true;
                break;
            case Qt.Key_Up:
            case Qt.Key_Right:
                if (flick.currentIndex < flick.count - 1)
                    flick.currentIndex += 1;
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
    property bool showSearchInput: false

    readonly property bool isPortrait: screen.height > screen.width

    // Target sizes
    property real targetWidth: isPortrait ? screen.width * 0.9 : screen.width * 0.6
    property real targetHeight: screen.height * 0.5

    ClippingRectangle {
        id: morphBox
        anchors.centerIn: parent

        width: Math.max(1, targetWidth * animProgress)
        height: Math.max(1, targetHeight * animProgress)

        scale: animProgress
        opacity: animProgress

        radius: Math.min(height, height) / 30

        transformOrigin: Item.Center
        color: Scripts.hexToRgba(Colors.background, 0.2)

        border.color: Scripts.hexToRgba(Colors.colors10, 1)
        border.width: 2

        x: Math.round(screen.width / 2 - width / 2)
        y: Math.round(screen.height / 2 - height / 2)

        ListContent {
            id: flick
            width: parent.width
            height: parent.height
            visible: animProgress > 0
            opacity: animProgress
            searchText: searchValue
        }

        Text {
            id: searchLabel
            text: qsTr(searchValue)
            font.pixelSize: 32
            font.bold: true
            anchors.centerIn: parent
            color: Colors.color15
            opacity: showSearchInput ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
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
