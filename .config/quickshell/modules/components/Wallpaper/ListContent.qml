import QtQuick
import QtQuick.Controls
import QtQuick.Shapes
import Quickshell
import Quickshell.Hyprland
import qs.services
import qs

ListView {
    id: flick
    clip: true
    orientation: ListView.Horizontal
    spacing: 20
    focus: true
    snapMode: ListView.SnapToItem
    boundsBehavior: Flickable.StopAtBounds

    highlightMoveDuration: 250
    highlightMoveVelocity: 400
    highlightFollowsCurrentItem: true
    highlightRangeMode: ListView.StrictlyEnforceRange

    preferredHighlightBegin: (width - delegateWidth) / 2
    preferredHighlightEnd: (width + delegateWidth) / 2

    model: ScriptModel {
        values: {
            const searchValue = morphBox.wallpaperSearch.trim().toLowerCase();

            const wallpapers = popup.isPortrait ? WallpaperStore.portraitWallpapers : WallpaperStore.landscapeWallpapers;

            function hexToHSL(hex) {
                const r = parseInt(hex.substr(1, 2), 16) / 255;
                const g = parseInt(hex.substr(3, 2), 16) / 255;
                const b = parseInt(hex.substr(5, 2), 16) / 255;

                const max = Math.max(r, g, b), min = Math.min(r, g, b);
                let h = 0, s = 0, l = (max + min) / 2;

                if (max !== min) {
                    const d = max - min;
                    s = l > 0.5 ? d / (2 - max - min) : d / (max + min);

                    switch (max) {
                    case r:
                        h = (g - b) / d + (g < b ? 6 : 0);
                        break;
                    case g:
                        h = (b - r) / d + 2;
                        break;
                    case b:
                        h = (r - g) / d + 4;
                        break;
                    }
                    h = h * 60;
                }

                return {
                    h,
                    s,
                    l
                };
            }

            function matchesKeywordColor(hex, keyword) {
                const hsl = hexToHSL(hex);
                const h = hsl.h;

                if (keyword === "purple")
                    return h >= 270 && h <= 310;
                if (keyword === "red")
                    return h <= 15 || h >= 345;
                if (keyword === "orange")
                    return h >= 20 && h <= 40;
                if (keyword === "yellow")
                    return h >= 41 && h <= 65;
                if (keyword === "green")
                    return h >= 66 && h <= 160;
                if (keyword === "blue")
                    return h >= 190 && h <= 250;
                if (keyword === "gray" || keyword === "grey")
                    return hsl.s <= 0.1 && hsl.l >= 0.2 && hsl.l <= 0.8;
                if (keyword === "dark")
                    return hsl.l < 0.3;
                if (keyword === "light")
                    return hsl.l > 0.7;

                return false;
            }

            const filtered = wallpapers.filter(w => {
                const color = (w.color ?? "").toLowerCase();
                const brightness = (w.brightness ?? "").toLowerCase();

                if (color.includes(searchValue) || brightness.includes(searchValue))
                    return true;

                return matchesKeywordColor(color, searchValue);
            });

            return filtered.sort((a, b) => a.color.localeCompare(b.color));
        }
    }

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Slash) {
            input.forceActiveFocus(); // 🔁 focus the search input
            event.accepted = true;
        }

        if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
            const index = flick.currentIndex;
            const model = flick.model;

            const path = model.values[index].path;
            const screenName = screen.name;
            WallpaperStore.setWallpaper(screenName, path);
            event.accepted = true;
        }

        // Optional: other key handling
        if (event.key === Qt.Key_Left) {
            if (flick.currentIndex > 0)
                flick.currentIndex -= 1;
            event.accepted = true;
        }

        if (event.key === Qt.Key_Right) {
            if (flick.currentIndex < flick.count - 1)
                flick.currentIndex += 1;
            event.accepted = true;
        }

        if (event.key === Qt.Key_Escape) {
            GlobalState.toggleDrawer("wallpaper");
            event.accepted = true;
        }
    }

    property int delegateWidth: popup.isPortrait ? width * 0.4 : width * 0.5
    property int delegateHeight: popup.isPortrait ? height * 0.9 : height * 0.8

    delegate: Item {

        width: flick.delegateWidth
        height: flick.delegateHeight
        anchors.verticalCenter: parent ? parent.verticalCenter : undefined

        Rectangle {
            id: container
            anchors.fill: parent
            anchors.margins: 8
            radius: 12
            clip: true

            property bool isFocused: ListView.isCurrentItem
            property real targetScale: isFocused || itemMouse.hovered ? 1.05 : 1.0
            property color targetColor: isFocused || itemMouse.hovered ? Colors.color4 : Colors.color2

            scale: targetScale
            color: targetColor

            Behavior on scale {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }

            Image {
                anchors.fill: parent
                anchors.margins: 8
                fillMode: Image.PreserveAspectFit
                source: "file://" + modelData.path
                cache: true
                asynchronous: true
                smooth: true
                mipmap: true
            }

            MouseArea {
                id: itemMouse
                anchors.fill: parent
                hoverEnabled: true
                property bool hovered: containsMouse

                onClicked: {
                    const screenName = toplevel.screen.name;
                    WallpaperStore.setWallpaper(screenName, modelData.path);
                }

                onEntered: hovered = true
                onExited: hovered = false
            }
        }
    }
}
