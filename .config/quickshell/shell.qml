//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
//@ pragma Env QML_XHR_ALLOW_FILE_READ=1
// Adjust this to make the shell smaller or larger
// @ pragma Env QT_SCALE_FACTOR=1
//@ pragma Env QT_QPA_PLATFORM=wayland

import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import qs.assets
import qs.bunservice
import qs.components
// component
import qs.modules
import qs.modules.appmenu
import qs.modules.volume
import qs.modules.bar
import qs.modules.extendedbar
import qs.modules.notification
import qs.modules.sessionmanager
import qs.modules.sessionmenu
import qs.modules.sidebar
import qs.modules.wallpaper
import qs.services

ShellRoot {
    id: root

    // Starts
    Connections {
        function onParseDone() {
            // http server
            Buns.startup();
        }

        target: ColorPalette
      }

    // FileView {
    //     id: settingsWatcher
    //     path: Qt.resolvedUrl("./settings.json");
    //     watchChanges: true
    //     onFileChanged: settingsWatcher.reload()
    //     onLoaded: {
    //        console.log("Settings loaded: ", settingsWatcher.text());
    //     }
    //     onLoadFailed: {
    //         console.log("Failed to load settings");
    //     }
    // }

    // NavBar
    Bar {}

    // SessionManager {}

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
