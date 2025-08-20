import QtQuick
import QtQuick.Controls
import QtQuick.Shapes

import Quickshell
import Quickshell.Hyprland

import qs.services
import qs.utils
import qs

ListView {
    id: flick
    property string searchText

    clip: true
    orientation: ListView.Horizontal
    spacing: 20

    snapMode: ListView.SnapToItem
    boundsBehavior: Flickable.StopAtBounds

    highlightMoveDuration: 250
    highlightMoveVelocity: 400
    highlightFollowsCurrentItem: true
    highlightRangeMode: ListView.StrictlyEnforceRange

    property int delegateWidth: Math.round(isPortrait ? width * 0.4 : width * 0.5)
    property int delegateHeight: Math.round(isPortrait ? height * 0.9 : height * 0.8)

    preferredHighlightBegin: (width - delegateWidth) / 2
    preferredHighlightEnd: (width + delegateWidth) / 2

    onCountChanged: {
        flick.currentIndex = 0;
    }

    model: ScriptModel {
        values: {
            const wallpapers = isPortrait ? WallpaperStore.portraitWallpapers : WallpaperStore.landscapeWallpapers;
            if (!flick.searchText || flick.searchText.trim() === "") {
                return wallpapers;
            }
            const search = flick.searchText.trim().toLowerCase();
            return wallpapers.filter(wallpaper => {
                // Check tags
                if (wallpaper.tags && wallpaper.tags.some(tag => tag.toLowerCase().includes(search))) {
                    return true;
                }
                // Check color tags
                if (wallpaper.colors && wallpaper.colors.some(c => c.tag && c.tag.toLowerCase().includes(search))) {
                    return true;
                }
                return false;
            });
        }
    }

    delegate: WallpaperItem {}

    add: Transition {
        NumberAnimation {
            properties: "opacity"
            from: 0
            to: 1
            duration: 300
            easing.type: Easing.InOutQuad
        }
        NumberAnimation {
            properties: "scale"
            from: 0
            to: 1
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }
    remove: Transition {
        NumberAnimation {
            properties: "opacity"
            from: 1
            to: 0
            duration: 300
            easing.type: Easing.InOutQuad
        }
        NumberAnimation {
            properties: "scale"
            from: 1
            to: 0
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }
}
