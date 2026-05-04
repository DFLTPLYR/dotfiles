pragma ComponentBehavior: Bound
import QtQuick

import Quickshell.Wayland
import qs.core
import qs.components
import qs.modules

Item {
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
            id: sessionLockSurface
            LockSurface {
                anchors.fill: parent
                context: lockContext
                monitor: sessionLockSurface.screen
            }
        }
    }
}
