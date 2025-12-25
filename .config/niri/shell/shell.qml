import QtQuick
import Quickshell
import Quickshell.Io

// imports
import qs.config
import qs.modules.navbar
import qs.modules.wallpaper
import qs.modules.sessionmenu
import qs.modules.notification

ShellRoot {
    id: root

    // App Launcher
    LazyLoader {
        active: false
    }

    // Navbar
    LazyLoader {
        active: true
        component: Bar {}
    }

    // Background Wallpaper
    LazyLoader {
        active: true
        component: WallOverlay {}
    }

    // Wallpaper Picker
    LazyLoader {
        active: true
        component: WallpaperPicker {}
    }

    // Volume OSD
    LazyLoader {
        active: true
        component: VolumeOsd {}
    }

    //Session Menu Overlay
    LazyLoader {
        active: Config.openSessionMenu
        component: SessionOverlay {}
    }
}
