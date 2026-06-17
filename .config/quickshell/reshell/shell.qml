//@ pragma Env QSG_RENDER_LOOP=threaded
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000

import QtQuick
import Quickshell
import qs.core
import qs.modules.overlay

ShellRoot {
    id: root

    LazyLoader {
        active: Global.general.greeter && Wallpaper.ready

        component: Greeter {}
    }

    Polkit {}

    Reshell {}
}
