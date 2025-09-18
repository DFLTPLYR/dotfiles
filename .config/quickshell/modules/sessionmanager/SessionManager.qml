import Quickshell

import Quickshell.Wayland

Singleton {
    LockContext {
        id: lockContext

        onUnlocked: {
            lock.locked = false;
        }
    }

    WlSessionLock {
        id: lock

        // Lock the session immediately when quickshell starts.
        locked: true

        WlSessionLockSurface {
            LockedSurface {
                anchors.fill: parent
                context: lockContext
                contextScreen: screen
            }
        }
    }
}
