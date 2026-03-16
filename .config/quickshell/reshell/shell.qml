import QtQuick
import QtQuick.Controls.Basic
import Quickshell
import Quickshell.Wayland
import qs
import qs.core
import qs.modules

ShellRoot {
    id: root

    LockContext {
        id: lockContext

        onUnlocked: {
            lock.locked = false;
        }
    }

    WlSessionLock {
        id: lock

        locked: Global.general.greeter

        WlSessionLockSurface {
            LockSurface {
                anchors.fill: parent
                context: lockContext
            }
        }
    }

    LazyLoader {
        active: !lock.locked
        component: Top {}
    }

    Background {}
    Overlay {}
}
