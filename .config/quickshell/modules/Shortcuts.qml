// WorkspaceShortcut.qml
import QtQuick
import Quickshell.Hyprland
import qs.services
import qs

Item {
    // WallpaperShortcut
    GlobalShortcut {
        id: wallpaperShortcutKeybind
        name: "showWallpaperCarousel"
        description: "Show Wallpaper Carousel to the current monitor"
    }

    Connections {
        target: wallpaperShortcutKeybind
        function onPressed() {
            GlobalState.toggleDrawer("wallpaper");
        }
    }

    // // ClipBoard
    // GlobalShortcut {
    //     id: clipBoard
    //     name: "showClipBoard"
    //     description: "Show Clipboard history"
    // }

    // Connections {
    //     target: clipBoard
    //     function onPressed() {
    //         GlobalState.toggleDrawer("clipBoard");
    //     }
    // }
}
