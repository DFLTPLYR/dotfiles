//@ pragma Env QSG_RENDER_LOOP=threaded
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000
//@ pragma Env WEATHER_API=API_KEY
//@ pragma DropExpensiveFonts=1
//@ pragma UseQApplication

pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Qt.labs.StyleKit
import qs.core
import qs.core.theme
import qs.modules.overlay.polkit
import qs.modules.overlay.greeter

ShellRoot {
    id: root
    reloadableId: "root"

    StyleKit.style: DefaultTheme {}

    LazyLoader {
        active: Global.general.greeter && Wallpaper.ready
        component: Greeter {}
    }

    Polkit {}

    Reshell {}
}
