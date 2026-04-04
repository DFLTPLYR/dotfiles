import Quickshell
import QtQuick
import QtQuick.Controls.Basic
import qs.core

ShellRoot {
    id: root

    LazyLoader {
        active: Global.general.greeter
        component: Greeter {}
    }
    Reshell {}
}
