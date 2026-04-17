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
