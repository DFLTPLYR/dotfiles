import QtQuick
import Quickshell
import Quickshell.Io

// imports
import qs.modules.navbar
import qs.modules.notification
import qs.modules.wallpaper

ShellRoot {
    id: root

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
    // LazyLoader {
    //     active: true
    //     component: WallpaperPicker {}
    // }

    // Volume OSD
    LazyLoader {
        active: true
        component: VolumeOsd {}
    }

    // App Launcher
    LazyLoader {
        active: false
    }
}
