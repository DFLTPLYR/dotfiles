//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
//@ pragma Env QML_XHR_ALLOW_FILE_READ=1
// Adjust this to make the shell smaller or larger
// @ pragma Env QT_SCALE_FACTOR=1
//@ pragma Env QT_QPA_PLATFORM=wayland

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick.Shapes
import Quickshell.Wayland

// component
import qs.modules
import qs.services
import qs.assets
import qs.components
import qs.bunservice

import qs.modules.bar
import qs.modules.sidebar
import qs.modules.appmenu
import qs.modules.extendedbar
import qs.modules.wallpaper
import qs.modules.sessionmenu
import qs.modules.notification
import qs.modules.sessionmanager

ShellRoot {
    id: root

    // Starts
    Connections {
        target: ColorPalette
        function onParseDone() {
            // http server
            Buns.startup();
        }
    }

    // SessionManager {}

    // NavBar
    Bar {}

    // Volume overlay
    VolumeOsd {}

    // Logout
    SessionMenu {}

    // right sidebar
    Sidebar {}

    // App menu
    AppMenu {}

    // Notification Overlay
    NotificationOsd {}

    WallpaperPicker {}
}
