import QtQuick
import Quickshell
import Quickshell.Io

// imports
import qs.modules.navbar
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

    LazyLoader {
        active: true
        component: WallpaperPicker {}
    }

    // App Launcher
    LazyLoader {
        active: false
    }
}
