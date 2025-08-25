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

    // Resource bar
    GlobalShortcut {
        id: resourceDashboard
        name: "showResourceBoard"
        description: "Show Resource Dashboard"
    }

    Connections {
        target: resourceDashboard
        function onPressed() {
            GlobalState.toggleDrawer("mpris");
        }
    }

    // App Menu
    GlobalShortcut {
        id: appMenu
        name: "showAppMenu"
        description: "Show Resource Dashboard"
    }

    Connections {
        target: appMenu
        function onPressed() {
            GlobalState.toggleDrawer("appMenu");
        }
    }

    // ClipBoard
    GlobalShortcut {
        id: clipBoard
        name: "showClipBoard"
        description: "Show Clipboard history"
    }

    Connections {
        target: clipBoard
        function onPressed() {
            GlobalState.toggleDrawer("clipBoard");
        }
    }
}
