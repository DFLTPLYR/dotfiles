import QtQuick

import Quickshell.Wayland
import qs.core
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
            LockSurface {
                anchors.fill: parent
                context: lockContext
            }
        }
    }
}
