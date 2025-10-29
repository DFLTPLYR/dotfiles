// GlobalState.qml
pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland

Singleton {
    id: root

    // Ui states
    property var openDrawers: []

    signal openDrawersUpdated
    signal openPanelsUpdated

    // signal Drawers
    signal showWallpaperCarouselSignal(bool value, string monitorName)
    signal showMprisChangedSignal(bool value, string monitorName)
    signal showAppMenuChangedSignal(bool value, string monitorName)
    signal showClipBoardChangedSignal(bool value, string monitorName)

    // signal Panels
    signal showSessionMenuChangedSignal(bool value)

    property bool debug: false
    property bool isSessionMenuOpen: false

    function toggleDrawer(type) {
        Hyprland.refreshMonitors();
        Qt.callLater(() => {
            const monitorName = Hyprland.focusedMonitor.name;

            const drawerMap = {
                wallpaper: {
                    keyPrefix: "WallpaperCarousel",
                    signal: showWallpaperCarouselSignal
                },
                mpris: {
                    keyPrefix: "MprisDashboard",
                    signal: showMprisChangedSignal
                },
                appMenu: {
                    keyPrefix: "AppMenu",
                    signal: showAppMenuChangedSignal
                },
                clipBoard: {
                    keyPrefix: "ClipBoard",
                    signal: showClipBoardChangedSignal
                }
            };

            const specialPanel = {
                logoutMenu: {
                    keyPrefix: "SessionMenu",
                    signal: showSessionMenuChangedSignal
                }
            };

            const isSpecial = !!specialPanel[type];
            const config = drawerMap[type] ? drawerMap[type] : isSpecial ? specialPanel[type] : (console.warn("Unknown drawer type:", type), null);
            if (!config)
                return;

            const drawerKey = isSpecial ? config.keyPrefix : `${config.keyPrefix}-${monitorName}`;

            const shouldBeVisible = !hasDrawer(drawerKey);

            if (shouldBeVisible) {
                addDrawer(drawerKey, isSpecial);
            }

            if (isSpecial) {
                config.signal(shouldBeVisible);
            } else {
                config.signal(shouldBeVisible, monitorName);
            }
        });
    }

    function addDrawer(name, isSpecial = false) {
        if (isSpecial) {
            openPanelsUpdated();
            return;
        }
        if (!openDrawers.includes(name)) {
            openDrawers.push(name);
            openDrawersUpdated();
        }
    }

    function removeDrawer(name, isSpecial = false) {
        if (isSpecial) {
            openPanelsUpdated();
            return;
        }
        let index = openDrawers.indexOf(name);
        if (index !== -1) {
            openDrawers.splice(index, 1);
            openDrawersUpdated();
        }
    }

    function hasDrawer(name) {
        return openDrawers.includes(name);
    }
}
