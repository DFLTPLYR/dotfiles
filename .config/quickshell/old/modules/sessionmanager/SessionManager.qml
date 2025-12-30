import Quickshell

import Quickshell.Wayland

Singleton {
    WlSessionLock {
        id: lock
        locked: true

        WlSessionLockSurface {
            LockedSurface {
                anchors.fill: parent
                context: lockContext
                contextScreen: screen
            }
        }
    }

    LockContext {
        id: lockContext
        onUnlocked: {
            lock.locked = false;
        }
    }
}
