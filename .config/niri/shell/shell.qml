import QtQuick
import Quickshell
import qs.modules.navbar

ShellRoot {
    id: root
    LazyLoader {
        active: true
        component: Bar {}
    }
    LazyLoader {
        active: false
    }
}
