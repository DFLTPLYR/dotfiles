// GlobalState.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland

PersistentProperties {
    id: root

    // Ui states
    property var openDrawers: []

    signal openDrawersUpdated

    signal drawer(string drawer)
    signal showWallpaperCarouselSignal(bool value, string monitorName)
    signal showMprisChangedSignal(bool value, string monitorName)
    signal showAppMenuChangedSignal(bool value, string monitorName)

    property bool debug: false

    function toggleDrawer(type) {
        Hyprland.refreshMonitors();
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
            }
            // Add more as needed...
        };

        const config = drawerMap[type];
        if (!config) {
            console.warn("Unknown drawer type:", type);
            return;
        }

        const drawerKey = `${config.keyPrefix}-${monitorName}`;
        const shouldBeVisible = !hasDrawer(drawerKey);

        if (shouldBeVisible) {
            addDrawer(drawerKey);
        }

        config.signal(shouldBeVisible, monitorName);
    }

    function addDrawer(name) {
        if (!openDrawers.includes(name)) {
            openDrawers.push(name);
            drawer(name);
            openDrawersUpdated();
        }
    }

    function removeDrawer(name) {
        let index = openDrawers.indexOf(name);
        if (index !== -1) {
            openDrawers.splice(index, 1);
            drawer(name);
            openDrawersUpdated();
        }
    }

    function hasDrawer(name) {
        return openDrawers.includes(name);
    }
}
