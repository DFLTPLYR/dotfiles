//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

// Adjust this to make the shell smaller or larger
// @ pragma Env QT_SCALE_FACTOR=1
//@ pragma Env QT_QPA_PLATFORM=wayland
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick.Shapes
import Quickshell.Wayland

// component
import qs.modules
import qs.services
import qs.assets
import qs.components

import qs.modules.bar
import qs.modules.appmenu
import qs.modules.extendedbar
import qs.modules.wallpaper
import qs.modules.logout

ShellRoot {
    Variants {
        // see Variants for details
        model: Quickshell.screens

        PanelWindow {
            id: screenRoot
            property var modelData
            screen: modelData

            focusable: persistStates.showAppMenu || persistStates.showMpris

            color: "transparent"
            implicitHeight: 42

            // margins {
            //     left: 10
            //     right: 10
            //     top: 10
            //     bottom: 10
            // }

            anchors {
                top: true
                left: true
                right: true
            }

            Bar {}

            LazyLoader {
                active: persistStates.showAppMenu
                component: AppMenu {}
            }

            LazyLoader {
                active: persistStates.showMpris
                component: ExtendedBar {}
            }

            LazyLoader {
                active: persistStates.showWallpaperCarousel
                component: WallpaperCarousel {}
            }

            Scope {
                PersistentProperties {
                    id: persistStates
                    reloadableId: "persistStates-" + screen.name
                    property bool showWallpaperCarousel: false
                    property bool showMpris: false
                    property bool showAppMenu: false
                    property bool showWindowsOptions: false
                }

                Connections {
                    target: GlobalState
                    function onOpenDrawersUpdated() {
                        const drawers = [
                            {
                                name: 'WallpaperCarousel',
                                property: 'showWallpaperCarousel'
                            },
                            {
                                name: 'MprisDashboard',
                                property: 'showMpris'
                            },
                            {
                                name: 'AppMenu',
                                property: 'showAppMenu'
                            },
                            {
                                name: 'WindowsOptions',
                                property: 'showWindowsOptions'
                            }
                        ];
                        const monitorName = screen.name;

                        for (let i = 0; i < drawers.length; i++) {
                            const drawer = drawers[i];
                            const uniqueKey = ['WindowsOptions'];

                            const key = uniqueKey.includes(drawer.name) ? drawer.name : `${drawer.name}-${monitorName}`;

                            const exists = GlobalState.hasDrawer(key);
                            persistStates[drawer.property] = exists;
                        }
                    }
                }
            }

            Component.onCompleted: {
                if (this.WlrLayershell != null) {
                    this.WlrLayershell.layer = WlrLayer.Top;
                }
            }
        }
    }

    Shortcuts {}

    VolumeOsd {}

    // LazyLoader {
    //     active: false
    //     component: Logout {}
    // }

    // starting singletons
    Component.onCompleted: {
        HardwareStats;
        MprisManager;
        WallpaperStore;
        WeatherFetcher;
        AppManager;
        Font;
    }
}
