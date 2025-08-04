// WorkspaceShortcut.qml
import QtQuick
import Quickshell.Hyprland
import qs.services
import qs
import Quickshell.Services.Mpris

Item {
    // WallpaperShortcut
    GlobalShortcut {
        id: cancelKeybind
        name: "cancel"
        description: "Cancel current action"
    }

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

    // WallpaperShortcut
    GlobalShortcut {
        id: debugKeybind
        name: "toggleDebug"
        description: "Show Wallpaper Carousel to the current monitor"
    }

    Connections {
        target: debugKeybind
        function onPressed() {
            // GlobalState.toggleMpris();
            GlobalState.toggleDrawer("mpris");
        }
    }
}
