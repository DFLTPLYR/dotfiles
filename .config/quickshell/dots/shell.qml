import QtQuick
import Quickshell
import qs.components
// imports
import qs.modules.app
import qs.modules.navbar
import qs.modules.notification
import qs.modules.sessionmenu
import qs.modules.settings
import qs.modules.wallpaper

ShellRoot {
    id: root

    // App Launcher
    AppMenu {}

    // Navbar
    Bar {}

    // Notifications
    Notifications {}

    // WallpaperBackground
    WallpaperBackground {}

    // Volume OSD
    VolumeOsd {}

    // Settings Panel
    SettingPanel {}

    //Session Menu Overlay
    SessionOverlay {}

    // Cutout Square
    Variants {
        // Put items in container:
        // container.content: [ ... ]

        model: Quickshell.screens

        delegate: Cutout {
            screen: modelData
        }
    }
}
