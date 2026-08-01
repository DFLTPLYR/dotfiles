//@ pragma Env QSG_RENDER_LOOP=threaded
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000
//@ pragma Env WEATHER_API=API_KEY_HERE

pragma ComponentBehavior: Bound
import QtQuick
import Quickshell

import qs.core
import qs.modules.overlay.polkit
import qs.modules.overlay.greeter

ShellRoot {
    id: root

    LazyLoader {
        active: Global.general.greeter && Wallpaper.ready
        component: Greeter {}
    }
    Polkit {}

    Reshell {}
}
