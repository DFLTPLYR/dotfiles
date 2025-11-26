//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QML_XHR_ALLOW_FILE_READ=1
// Adjust this to make the shell smaller or larger
//@ pragma Env QT_SCALE_FACTOR=1
//@ pragma Env QT_QPA_PLATFORM=wayland

import QtQuick
import Quickshell
import qs.assets
import qs.components
// component

import qs.services
import qs.config
import qs.modules.appmenu
import qs.modules.bar
import qs.modules.clipboard
import qs.modules.extendedbar
import qs.modules.notification
import qs.modules.sessionmanager
import qs.modules.screenrecorder
import qs.modules.sessionmenu
import qs.modules.sidebar
import qs.modules.settings
import qs.modules.volume
import qs.modules.wallpaper
import qs.modules.webserver

ShellRoot {
    id: root

    // NavBar
    LazyLoader {
        active: Config.loaded
        Bar {}
    }

    // Clipboard Overlay
    Clipboard {}

    // SessionManager {}

    // Volume overlay
    VolumeOsd {}

    // Logout

    SessionMenu {}
    // right sidebar
    // Sidebar {}

    // App menu

    AppMenu {}
    // Notification Overlay

    NotificationOsd {}

    WallpaperPicker {}

    ConfigPanel {}
    // Settings Panel

    // Screen Overlay
    ScreenOverLay {}
}
