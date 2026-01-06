import QtQuick
import Quickshell
import Quickshell.Io

// imports
import qs.config
import qs.modules.app
import qs.modules.navbar
import qs.modules.wallpaper
import qs.modules.sessionmenu
import qs.modules.notification
import qs.modules.settings

ShellRoot {
    id: root

    // App Launcher
    AppMenu {}

    // Navbar
    Bar {}

    // Notifications
    Notifications {}

    // Wallpaper Picker
    WallpaperPicker {}

    // Volume OSD
    VolumeOsd {}

    //Session Menu Overlay
    SessionOverlay {}
    SettingPanel {}
    WallpaperBackground {}
}
