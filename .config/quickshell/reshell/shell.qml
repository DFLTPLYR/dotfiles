//@ pragma Env QSG_RENDER_LOOP=threaded
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000

import Quickshell
import QtQuick
import qs.core

ShellRoot {
    id: root

    LazyLoader {
        active: Global.general.greeter
        component: Greeter {}
    }
    Reshell {}
}
