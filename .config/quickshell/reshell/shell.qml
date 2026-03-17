import QtQuick
import Quickshell
import qs
import qs.core
import qs.modules

ShellRoot {
    id: root

    LazyLoader {
        active: Global.general.greeter
        component: Greeter {}
    }
    LazyLoader {
        active: !Global.general.greeter
        component: Reshell {}
    }
}
